import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/features/addresses/domain/entities/address.dart';
import 'package:ssm/features/addresses/domain/repos/address_repository.dart';
import 'package:ssm/features/cart/domain/entities/cart.dart';
import 'package:ssm/features/catalog/domain/entities/store.dart';
import 'package:ssm/features/checkout/domain/entities/order_quote.dart';
import 'package:ssm/features/checkout/domain/entities/order_request.dart';
import 'package:ssm/features/checkout/domain/repos/checkout_repository.dart';
import 'package:ssm/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:ssm/features/checkout/presentation/cubit/checkout_state.dart';
import 'package:ssm/features/checkout/presentation/utils/checkout_messages.dart';

import '../../helpers/fake_catalog_repository.dart';
import '../../helpers/test_strings.dart';

class _FakeAddressRepository implements AddressRepository {
  Either<Failure, List<Address>> answer = const Right<Failure, List<Address>>(
    <Address>[_home, _office],
  );

  @override
  Future<Either<Failure, List<Address>>> getAddresses() async => answer;

  @override
  Future<Either<Failure, Unit>> addAddress(NewAddress address) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> deleteAddress(int id) =>
      throw UnimplementedError();
}

/// Answers store details at once, and counts the calls.
class _FakeStores extends FakeCatalogRepository {
  Either<Failure, Store> answer = const Right<Failure, Store>(_store);
  int calls = 0;

  @override
  Future<Either<Failure, Store>> getStoreDetails(int storeId) async {
    calls++;
    return answer;
  }
}

class _FakeCheckoutRepository implements CheckoutRepository {
  final List<QuoteRequest> quotes = <QuoteRequest>[];
  Either<Failure, OrderQuote> quoteAnswer = const Right<Failure, OrderQuote>(
    _quote,
  );

  /// When set, quotes wait on it — lets a test change inputs mid-quote.
  Completer<void>? quoteGate;

  final List<(OrderRequest, String)> placed = <(OrderRequest, String)>[];
  Completer<Either<Failure, PlacedOrder>> answer = Completer();

  @override
  Future<Either<Failure, OrderQuote>> getQuote(QuoteRequest request) async {
    quotes.add(request);
    await quoteGate?.future;
    return quoteAnswer;
  }

  @override
  Future<Either<Failure, PlacedOrder>> placeOrder(
    OrderRequest request, {
    required String idempotencyKey,
  }) {
    placed.add((request, idempotencyKey));
    return answer.future;
  }

  /// Answers the pending placement and gets ready for the next one.
  void answerPlacement(Either<Failure, PlacedOrder> result) {
    final Completer<Either<Failure, PlacedOrder>> pending = answer;
    answer = Completer();
    pending.complete(result);
  }
}

const Address _home = Address(
  id: 3,
  type: AddressType.home,
  contactPersonName: 'Sara Customer',
  contactPersonNumber: '+966512345678',
  address: 'Olaya St 12, Riyadh',
  location: GeoPoint(latitude: 24.71, longitude: 46.68),
  zoneId: 1,
);

const Address _office = Address(
  id: 4,
  type: AddressType.office,
  contactPersonName: 'Sara Customer',
  contactPersonNumber: '+966512345678',
  address: 'King Fahd Rd 5, Riyadh',
  location: GeoPoint(latitude: 24.75, longitude: 46.70),
  zoneId: 2,
);

const Address _unpinned = Address(
  id: 5,
  type: AddressType.other,
  contactPersonName: 'Sara Customer',
  contactPersonNumber: '+966512345678',
  address: 'Somewhere',
);

const Store _store = Store(
  id: 7,
  name: 'Burger Place',
  location: GeoPoint(latitude: 24.70, longitude: 46.67),
);

const OrderQuote _quote = OrderQuote(
  subtotal: 40,
  deliveryCharge: 7,
  tax: 6.05,
  total: 53.05,
  currency: 'SAR',
);

final Cart _cart = Cart(const <CartLine>[
  CartLine(
    id: 1,
    itemId: 10,
    name: 'Burger',
    unitPrice: 20,
    quantity: 2,
    storeId: 7,
  ),
]);

/// Bloc delivers stream events asynchronously — let them arrive.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late _FakeAddressRepository addresses;
  late _FakeStores stores;
  late _FakeCheckoutRepository checkout;
  late CheckoutCubit cubit;
  late int keys;
  late List<CheckoutNotice> notices;
  late StreamSubscription<CheckoutState> subscription;

  setUp(() {
    addresses = _FakeAddressRepository();
    stores = _FakeStores();
    checkout = _FakeCheckoutRepository();
    keys = 0;
    cubit = CheckoutCubit(
      checkoutRepository: checkout,
      addressRepository: addresses,
      catalogRepository: stores,
      newIdempotencyKey: () => 'key-${++keys}',
    );
    notices = <CheckoutNotice>[];
    subscription = cubit.stream.listen((CheckoutState state) {
      if (state.notice case final CheckoutNotice notice) notices.add(notice);
    });
  });

  tearDown(() async {
    await subscription.cancel();
    await cubit.close();
  });

  /// Addresses loaded, cart handed over, quote ready.
  Future<void> ready() async {
    await cubit.loadAddresses();
    await cubit.updateCart(_cart);
  }

  group('addresses', () {
    test('loads the saved addresses and preselects the first', () async {
      await cubit.loadAddresses();

      expect(
        cubit.state.addresses,
        const CheckoutAddressesLoaded(<Address>[_home, _office]),
      );
      expect(cubit.state.selectedAddress, _home);
    });

    test('a failed address load is an error the screen can retry', () async {
      addresses.answer = const Left<Failure, List<Address>>(NetworkFailure());

      await cubit.loadAddresses();

      expect(
        cubit.state.addresses,
        const CheckoutAddressesError(NetworkFailure()),
      );
    });
  });

  group('quote', () {
    test('waits for both the cart and the addresses', () async {
      await cubit.updateCart(_cart);

      expect(cubit.state.quote, const CheckoutQuotePending());
      expect(checkout.quotes, isEmpty);
    });

    test('shows the server quote for the cart and address', () async {
      await ready();

      expect(cubit.state.quote, isA<CheckoutQuoteReady>());
      expect((cubit.state.quote as CheckoutQuoteReady).quote, _quote);
    });

    test('asks for the store-to-address distance', () async {
      await ready();

      final QuoteRequest request = checkout.quotes.single;
      expect(request.storeId, 7);
      expect(
        request.distanceKm,
        closeTo(_store.location!.distanceKmTo(_home.location!), 1e-9),
      );
    });

    test('a new address is re-quoted', () async {
      await ready();

      await cubit.selectAddress(_office.id);

      expect(checkout.quotes, hasLength(2));
      expect(
        checkout.quotes.last.distanceKm,
        closeTo(_store.location!.distanceKmTo(_office.location!), 1e-9),
      );
    });

    test('re-selecting the same address is not re-quoted', () async {
      await ready();

      await cubit.selectAddress(_home.id);

      expect(checkout.quotes, hasLength(1));
    });

    test('the same cart again is not re-quoted', () async {
      await ready();

      await cubit.updateCart(Cart(List<CartLine>.of(_cart.lines)));

      expect(checkout.quotes, hasLength(1));
    });

    test('fetches the store pin once', () async {
      await ready();

      await cubit.selectAddress(_office.id);
      await cubit.selectAddress(_home.id);

      expect(stores.calls, 1);
    });

    test('an address without a pin cannot be quoted', () async {
      addresses.answer = const Right<Failure, List<Address>>(<Address>[
        _unpinned,
      ]);

      await ready();

      expect(
        cubit.state.quote,
        const CheckoutQuoteUnavailable(CheckoutIssue.addressWithoutLocation),
      );
      expect(checkout.quotes, isEmpty);
    });

    test('a store without a pin cannot be quoted', () async {
      stores.answer = const Right<Failure, Store>(Store(id: 7, name: 'x'));

      await ready();

      expect(
        cubit.state.quote,
        const CheckoutQuoteUnavailable(CheckoutIssue.storeWithoutLocation),
      );
    });

    test('a cart without a store id cannot be quoted', () async {
      await cubit.loadAddresses();

      await cubit.updateCart(
        Cart(const <CartLine>[
          CartLine(id: 1, itemId: 10, name: 'x', unitPrice: 1, quantity: 1),
        ]),
      );

      expect(
        cubit.state.quote,
        const CheckoutQuoteUnavailable(CheckoutIssue.unknownStore),
      );
    });

    test('a failed quote is an error the screen can retry', () async {
      checkout.quoteAnswer = const Left<Failure, OrderQuote>(NetworkFailure());
      await ready();
      expect(cubit.state.quote, const CheckoutQuoteError(NetworkFailure()));

      checkout.quoteAnswer = const Right<Failure, OrderQuote>(_quote);
      await cubit.retryQuote();

      expect(cubit.state.quote, isA<CheckoutQuoteReady>());
    });

    test('a failed store lookup is an error, retried with the quote', () async {
      stores.answer = const Left<Failure, Store>(NetworkFailure());
      await ready();
      expect(cubit.state.quote, const CheckoutQuoteError(NetworkFailure()));

      stores.answer = const Right<Failure, Store>(_store);
      await cubit.retryQuote();

      expect(cubit.state.quote, isA<CheckoutQuoteReady>());
    });

    test('an answer for a since-changed address is dropped', () async {
      await cubit.loadAddresses();
      checkout.quoteGate = Completer<void>();
      final Future<void> first = cubit.updateCart(_cart);
      await _settle();

      // The customer switches to an address without a pin meanwhile.
      addresses.answer = const Right<Failure, List<Address>>(<Address>[
        _unpinned,
      ]);
      await cubit.loadAddresses();
      checkout.quoteGate!.complete();
      await first;

      expect(
        cubit.state.quote,
        const CheckoutQuoteUnavailable(CheckoutIssue.addressWithoutLocation),
      );
    });
  });

  group('placing', () {
    test(
      'places at the quoted distance and total, in the address zone',
      () async {
        await ready();
        await cubit.selectAddress(_office.id);
        final double distance =
            (cubit.state.quote as CheckoutQuoteReady).distanceKm;

        final Future<void> place = cubit.placeOrder(_cart);
        expect(cubit.state.placing, isTrue);
        checkout.answerPlacement(
          const Right<Failure, PlacedOrder>(
            PlacedOrder(id: 9, totalAmount: 53),
          ),
        );
        await place;

        expect(
          checkout.placed.single.$1,
          OrderRequest(
            storeId: 7,
            orderAmount: 53.05,
            distanceKm: distance,
            deliveryAddress: 'King Fahd Rd 5, Riyadh',
            location: const GeoPoint(latitude: 24.75, longitude: 46.70),
            contactPersonName: 'Sara Customer',
            contactPersonNumber: '+966512345678',
            zoneId: 2,
          ),
        );
        expect(
          cubit.state.placedOrder,
          const PlacedOrder(id: 9, totalAmount: 53),
        );
        expect(cubit.state.placing, isFalse);
      },
    );

    test('sends nothing without a ready quote', () async {
      checkout.quoteAnswer = const Left<Failure, OrderQuote>(NetworkFailure());
      await ready();

      await cubit.placeOrder(_cart);

      expect(checkout.placed, isEmpty);
    });

    test('a second tap while placing sends nothing more', () async {
      await ready();

      final Future<void> first = cubit.placeOrder(_cart);
      await cubit.placeOrder(_cart);
      checkout.answerPlacement(
        const Right<Failure, PlacedOrder>(PlacedOrder(id: 9)),
      );
      await first;
      await cubit.placeOrder(_cart);

      expect(checkout.placed, hasLength(1));
    });

    test('a refusal keeps the form and reports the failure', () async {
      await ready();

      final Future<void> place = cubit.placeOrder(_cart);
      checkout.answerPlacement(
        const Left<Failure, PlacedOrder>(
          ForbiddenFailure(message: 'Out of coverage!', code: 'coordinates'),
        ),
      );
      await place;
      await _settle();

      expect(cubit.state.placing, isFalse);
      expect(cubit.state.placedOrder, isNull);
      expect(notices, <CheckoutNotice>[
        const CheckoutFailed(
          1,
          ForbiddenFailure(message: 'Out of coverage!', code: 'coordinates'),
        ),
      ]);
    });
  });

  group('idempotency key', () {
    Future<void> attempt(Either<Failure, PlacedOrder> result) async {
      final Future<void> place = cubit.placeOrder(_cart);
      checkout.answerPlacement(result);
      await place;
    }

    test('each order attempt sends a key', () async {
      await ready();

      await attempt(const Right<Failure, PlacedOrder>(PlacedOrder(id: 9)));

      expect(checkout.placed.single.$2, 'key-1');
    });

    test('a retry after a lost answer reuses the key', () async {
      await ready();

      await attempt(const Left<Failure, PlacedOrder>(NetworkFailure()));
      await attempt(const Right<Failure, PlacedOrder>(PlacedOrder(id: 9)));

      expect(checkout.placed.map((p) => p.$2), <String>['key-1', 'key-1']);
    });

    test(
      'a retry while the first is still processing reuses the key',
      () async {
        await ready();

        await attempt(
          const Left<Failure, PlacedOrder>(
            ConflictFailure(code: IdempotencyCode.inProgress),
          ),
        );
        await attempt(const Right<Failure, PlacedOrder>(PlacedOrder(id: 9)));

        expect(checkout.placed.map((p) => p.$2), <String>['key-1', 'key-1']);
      },
    );

    test('a refused order gets a new key next time', () async {
      await ready();

      await attempt(
        const Left<Failure, PlacedOrder>(
          ForbiddenFailure(code: 'order_amount'),
        ),
      );
      await attempt(const Right<Failure, PlacedOrder>(PlacedOrder(id: 9)));

      expect(checkout.placed.map((p) => p.$2), <String>['key-1', 'key-2']);
    });

    test('a different order gets a new key', () async {
      await ready();

      await attempt(const Left<Failure, PlacedOrder>(NetworkFailure()));
      await cubit.selectAddress(_office.id);
      await attempt(const Right<Failure, PlacedOrder>(PlacedOrder(id: 9)));

      expect(checkout.placed.map((p) => p.$2), <String>['key-1', 'key-2']);
    });
  });

  group('CheckoutNotice.message', () {
    setUpAll(installEnglishStrings);
    tearDownAll(removeTestStrings);

    test('explains the known refusals in our own words', () {
      expect(
        const CheckoutFailed(
          1,
          ForbiddenFailure(message: 'Out of coverage!', code: 'coordinates'),
        ).message,
        'This address is outside the delivery area. Choose another address.',
      );
      expect(
        const CheckoutFailed(
          1,
          ForbiddenFailure(message: 'x', code: 'order_amount'),
        ).message,
        'This order is above the cash-on-delivery limit. '
        'Remove some items and try again.',
      );
    });

    test('tells the customer an order is still being processed', () {
      expect(
        const CheckoutFailed(
          1,
          ConflictFailure(code: IdempotencyCode.inProgress),
        ).message,
        'Your order is still being processed. '
        'Check My Orders before trying again.',
      );
    });

    test('shows the server message for any other refusal', () {
      expect(
        const CheckoutFailed(
          1,
          ForbiddenFailure(message: 'Store is closed', code: 'store'),
        ).message,
        'Store is closed',
      );
    });
  });
}
