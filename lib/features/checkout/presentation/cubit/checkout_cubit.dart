import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../addresses/domain/entities/address.dart';
import '../../../addresses/domain/repos/address_repository.dart';
import '../../../cart/domain/entities/cart.dart';
import '../../domain/entities/order_request.dart';
import '../../domain/repos/checkout_repository.dart';
import 'checkout_state.dart';

/// Screen-scoped (one per checkout route). The cart comes from the
/// screen's `CartCubit` and is handed to [placeOrder].
class CheckoutCubit extends Cubit<CheckoutState> {
  final CheckoutRepository checkoutRepository;
  final AddressRepository addressRepository;

  CheckoutCubit({
    required this.checkoutRepository,
    required this.addressRepository,
  }) : super(const CheckoutState());

  int _noticeSeq = 0;

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
          placing: state.placing,
          placedOrder: state.placedOrder,
        ),
      ),
    );
  }

  void selectAddress(int addressId) =>
      emit(state.copyWith(addressId: addressId));

  /// Checks [cart] and the chosen address, then places the order. Ignored
  /// while an order is on its way or once one is placed.
  Future<void> placeOrder(Cart cart) async {
    if (state.placing || state.placedOrder != null) return;
    final OrderRequest? request = _requestFor(cart);
    if (request == null) return;

    emit(state.copyWith(placing: true));
    final Either<Failure, PlacedOrder> result = await checkoutRepository
        .placeOrder(request);
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

  /// Null (with a notice) when something is missing.
  OrderRequest? _requestFor(Cart cart) {
    final int? storeId = cart.lines.firstOrNull?.storeId;
    final Address? address = state.selectedAddress;
    final GeoPoint? location = address?.location;
    if (cart.isEmpty) return _incomplete(CheckoutIssue.emptyCart);
    if (storeId == null) return _incomplete(CheckoutIssue.unknownStore);
    if (address == null) return _incomplete(CheckoutIssue.noAddress);
    if (location == null) {
      return _incomplete(CheckoutIssue.addressWithoutLocation);
    }
    return OrderRequest(
      storeId: storeId,
      orderAmount: cart.subtotal,
      deliveryAddress: address.address,
      location: location,
      contactPersonName: address.contactPersonName,
      contactPersonNumber: address.contactPersonNumber,
      zoneId: address.zoneId,
    );
  }

  Null _incomplete(CheckoutIssue issue) {
    emit(state.copyWith(notice: CheckoutIncomplete(++_noticeSeq, issue)));
    return null;
  }
}
