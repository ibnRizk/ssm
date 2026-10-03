import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/uuid.dart';
import '../../../addresses/domain/entities/address.dart';
import '../../../addresses/domain/repos/address_repository.dart';
import '../../../cart/domain/entities/cart.dart';
import '../../../catalog/domain/entities/store.dart';
import '../../../catalog/domain/repos/catalog_repository.dart';
import '../../domain/entities/order_quote.dart';
import '../../domain/entities/order_request.dart';
import '../../domain/repos/checkout_repository.dart';
import 'checkout_state.dart';

/// Screen-scoped (one per checkout route). The screen hands over the cart
/// from its `CartCubit` ([updateCart]); every change of cart or address is
/// re-quoted by the server, and the order can only be placed on a ready
/// quote — the customer always confirms the server's total.
class CheckoutCubit extends Cubit<CheckoutState> {
  final CheckoutRepository checkoutRepository;
  final AddressRepository addressRepository;
  final CatalogRepository catalogRepository;

  /// One per checkout attempt; swapped in tests for predictable keys.
  final String Function() newIdempotencyKey;

  CheckoutCubit({
    required this.checkoutRepository,
    required this.addressRepository,
    required this.catalogRepository,
    this.newIdempotencyKey = uuidV4,
  }) : super(const CheckoutState());

  int _noticeSeq = 0;

  /// Bumped per quote request, so a slow answer for an address the
  /// customer has since changed is dropped.
  int _quoteSeq = 0;

  Cart? _cart;

  /// Store pins don't move during a checkout — fetched once per store.
  final Map<int, Store> _stores = <int, Store>{};

  /// The last placing attempt whose outcome is unknown (lost answer). The
  /// same request is retried with the same key so the server can't create
  /// a second order; any other request gets a new key.
  (OrderRequest, String)? _attempt;

  /// Keeps the chosen address when it still exists; otherwise picks the
  /// first one.
  Future<void> loadAddresses() async {
    emit(state.copyWith(addresses: const CheckoutAddressesLoading()));
    final Either<Failure, List<Address>> result = await addressRepository
        .getAddresses();
    if (isClosed) return;
    result.fold(
      (Failure failure) =>
          emit(state.copyWith(addresses: CheckoutAddressesError(failure))),
      (List<Address> addresses) => emit(
        CheckoutState(
          addresses: CheckoutAddressesLoaded(addresses),
          addressId: addresses.any((Address a) => a.id == state.addressId)
              ? state.addressId
              : addresses.firstOrNull?.id,
          quote: state.quote,
          placing: state.placing,
          placedOrder: state.placedOrder,
        ),
      ),
    );
    await _requote();
  }

  Future<void> selectAddress(int addressId) async {
    if (addressId == state.addressId) return;
    emit(state.copyWith(addressId: addressId));
    await _requote();
  }

  /// The cart as it now is. Only a changed cart is re-quoted.
  Future<void> updateCart(Cart cart) async {
    if (cart == _cart) return;
    _cart = cart;
    await _requote();
  }

  Future<void> retryQuote() => _requote();

  /// Places [cart] at the quoted price. Ignored while an order is on its
  /// way, once one is placed, or without a ready quote for this very cart.
  Future<void> placeOrder(Cart cart) async {
    if (state.placing || state.placedOrder != null) return;
    if (cart != _cart) return updateCart(cart);
    final CheckoutQuote quote = state.quote;
    if (quote is! CheckoutQuoteReady) return;
    final OrderRequest? request = _requestFor(cart, quote);
    if (request == null) return;

    final String key = switch (_attempt) {
      (final OrderRequest previous, final String key)
          when previous == request =>
        key,
      _ => newIdempotencyKey(),
    };
    _attempt = (request, key);

    emit(state.copyWith(placing: true));
    final Either<Failure, PlacedOrder> result = await checkoutRepository
        .placeOrder(request, idempotencyKey: key);
    if (!result.fold(_outcomeUnknown, (_) => false)) _attempt = null;
    if (isClosed) return;
    result.fold(
      (Failure failure) => emit(
        state.copyWith(
          placing: false,
          notice: CheckoutFailed(++_noticeSeq, failure),
        ),
      ),
      (PlacedOrder order) =>
          emit(state.copyWith(placing: false, placedOrder: order)),
    );
  }

  /// The order may or may not exist — keep the key for the retry.
  static bool _outcomeUnknown(Failure failure) => switch (failure) {
    NetworkFailure() || ServerFailure() => true,
    ConflictFailure(:final String? code) => code == IdempotencyCode.inProgress,
    _ => false,
  };

  Future<void> _requote() async {
    if (state.placedOrder != null) return;
    final Cart? cart = _cart;
    if (cart == null || state.addresses is! CheckoutAddressesLoaded) {
      return _setQuote(const CheckoutQuotePending());
    }
    final Address? address = state.selectedAddress;
    final int? storeId = cart.lines.firstOrNull?.storeId;
    final CheckoutIssue? issue = _issueFor(cart, storeId, address);
    if (issue != null) return _setQuote(CheckoutQuoteUnavailable(issue));

    final int seq = ++_quoteSeq;
    _setQuote(const CheckoutQuoteLoading());
    final CheckoutQuote quote = await _fetchQuote(storeId!, address!.location!);
    if (isClosed || seq != _quoteSeq) return;
    _setQuote(quote);
  }

  void _setQuote(CheckoutQuote quote) {
    if (quote is! CheckoutQuoteLoading) _quoteSeq++;
    emit(state.copyWith(quote: quote));
  }

  Future<CheckoutQuote> _fetchQuote(int storeId, GeoPoint destination) async {
    final Either<Failure, Store> store = await _store(storeId);
    if (store case Left<Failure, Store>(:final Failure value)) {
      return CheckoutQuoteError(value);
    }
    final GeoPoint? origin = store
        .getOrElse(() => throw StateError('unreachable: Left handled above'))
        .location;
    if (origin == null) {
      return const CheckoutQuoteUnavailable(CheckoutIssue.storeWithoutLocation);
    }
    final double distanceKm = origin.distanceKmTo(destination);
    final Either<Failure, OrderQuote> quote = await checkoutRepository.getQuote(
      QuoteRequest(storeId: storeId, distanceKm: distanceKm),
    );
    return quote.fold(
      CheckoutQuoteError.new,
      (OrderQuote q) => CheckoutQuoteReady(q, distanceKm: distanceKm),
    );
  }

  Future<Either<Failure, Store>> _store(int storeId) async {
    final Store? cached = _stores[storeId];
    if (cached != null) return Right<Failure, Store>(cached);
    final Either<Failure, Store> result = await catalogRepository
        .getStoreDetails(storeId);
    result.fold((_) {}, (Store store) => _stores[storeId] = store);
    return result;
  }

  /// What stops [cart] from being quoted or ordered for [address]; null
  /// when nothing does.
  static CheckoutIssue? _issueFor(Cart cart, int? storeId, Address? address) {
    if (cart.isEmpty) return CheckoutIssue.emptyCart;
    if (storeId == null) return CheckoutIssue.unknownStore;
    if (address == null) return CheckoutIssue.noAddress;
    if (address.location == null) return CheckoutIssue.addressWithoutLocation;
    return null;
  }

  /// Null (with a notice) when something is missing.
  OrderRequest? _requestFor(Cart cart, CheckoutQuoteReady quote) {
    final int? storeId = cart.lines.firstOrNull?.storeId;
    final Address? address = state.selectedAddress;
    final CheckoutIssue? issue = _issueFor(cart, storeId, address);
    if (issue != null) {
      emit(state.copyWith(notice: CheckoutIncomplete(++_noticeSeq, issue)));
      return null;
    }
    return OrderRequest(
      storeId: storeId!,
      orderAmount: quote.quote.total,
      distanceKm: quote.distanceKm,
      deliveryAddress: address!.address,
      location: address.location!,
      contactPersonName: address.contactPersonName,
      contactPersonNumber: address.contactPersonNumber,
      zoneId: address.zoneId,
    );
  }
}
