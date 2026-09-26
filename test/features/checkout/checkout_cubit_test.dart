import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_base/core/error/failures.dart';
import 'package:flutter_base/features/addresses/domain/entities/address.dart';
import 'package:flutter_base/features/addresses/domain/repos/address_repository.dart';
import 'package:flutter_base/features/cart/domain/entities/cart.dart';
import 'package:flutter_base/features/checkout/domain/entities/order_request.dart';
import 'package:flutter_base/features/checkout/domain/repos/checkout_repository.dart';
import 'package:flutter_base/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:flutter_base/features/checkout/presentation/cubit/checkout_state.dart';
import 'package:flutter_base/features/checkout/presentation/utils/checkout_messages.dart';
import 'package:flutter_test/flutter_test.dart';

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

class _FakeCheckoutRepository implements CheckoutRepository {
  final List<OrderRequest> placed = <OrderRequest>[];
  Completer<Either<Failure, PlacedOrder>> answer = Completer();

  @override
  Future<Either<Failure, PlacedOrder>> placeOrder(OrderRequest request) {
    placed.add(request);
    return answer.future;
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
  late _FakeCheckoutRepository checkout;
  late CheckoutCubit cubit;
  late List<CheckoutNotice> notices;
  late StreamSubscription<CheckoutState> subscription;

  setUp(() {
    addresses = _FakeAddressRepository();
    checkout = _FakeCheckoutRepository();
    cubit = CheckoutCubit(
      checkoutRepository: checkout,
      addressRepository: addresses,
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

  test('places the cart for the chosen address, in its zone', () async {
    await cubit.loadAddresses();
    cubit.selectAddress(_office.id);

    final Future<void> place = cubit.placeOrder(_cart);
    expect(cubit.state.placing, isTrue);
    checkout.answer.complete(
      const Right<Failure, PlacedOrder>(PlacedOrder(id: 9, totalAmount: 50)),
    );
    await place;

    expect(
      checkout.placed.single,
      const OrderRequest(
        storeId: 7,
        orderAmount: 40,
        deliveryAddress: 'King Fahd Rd 5, Riyadh',
        location: GeoPoint(latitude: 24.75, longitude: 46.70),
        contactPersonName: 'Sara Customer',
        contactPersonNumber: '+966512345678',
        zoneId: 2,
      ),
    );
    expect(cubit.state.placedOrder, const PlacedOrder(id: 9, totalAmount: 50));
    expect(cubit.state.placing, isFalse);
  });

  test('a second tap while placing sends nothing more', () async {
    await cubit.loadAddresses();

    final Future<void> first = cubit.placeOrder(_cart);
    await cubit.placeOrder(_cart);
    checkout.answer.complete(
      const Right<Failure, PlacedOrder>(PlacedOrder(id: 9)),
    );
    await first;
    await cubit.placeOrder(_cart);

    expect(checkout.placed, hasLength(1));
  });

  test('a refusal keeps the form and reports the failure', () async {
    await cubit.loadAddresses();

    final Future<void> place = cubit.placeOrder(_cart);
    checkout.answer.complete(
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

  test('says what is missing, without sending', () async {
    addresses.answer = const Right<Failure, List<Address>>(<Address>[
      _unpinned,
    ]);
    await cubit.placeOrder(Cart.empty);
    await cubit.placeOrder(_cart);
    await cubit.loadAddresses();
    await cubit.placeOrder(_cart);
    await _settle();

    expect(notices, <CheckoutNotice>[
      const CheckoutIncomplete(1, CheckoutIssue.emptyCart),
      const CheckoutIncomplete(2, CheckoutIssue.noAddress),
      const CheckoutIncomplete(3, CheckoutIssue.addressWithoutLocation),
    ]);
    expect(checkout.placed, isEmpty);
  });

  test('a cart without a store id is not sent', () async {
    await cubit.loadAddresses();

    await cubit.placeOrder(
      Cart(const <CartLine>[
        CartLine(id: 1, itemId: 10, name: 'x', unitPrice: 1, quantity: 1),
      ]),
    );
    await _settle();

    expect(
      notices.single,
      const CheckoutIncomplete(1, CheckoutIssue.unknownStore),
    );
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
