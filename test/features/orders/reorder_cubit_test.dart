import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/features/cart/domain/entities/cart.dart';
import 'package:ssm/features/cart/domain/repos/cart_repository.dart';
import 'package:ssm/features/catalog/domain/entities/catalog_page.dart';
import 'package:ssm/features/orders/domain/entities/order_list_entry.dart';
import 'package:ssm/features/orders/domain/repos/orders_repository.dart';
import 'package:ssm/features/orders/presentation/cubit/reorder_cubit.dart';
import 'package:ssm/features/orders/presentation/cubit/reorder_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeOrdersRepository implements OrdersRepository {
  Either<Failure, List<OrderedItem>> items =
      const Right<Failure, List<OrderedItem>>(<OrderedItem>[
        OrderedItem(itemId: 10, storeId: 7, quantity: 2, unitPrice: 20),
        OrderedItem(itemId: 11, storeId: 7, quantity: 1, unitPrice: 5),
      ]);

  /// When set, [getOrderedItems] waits for it.
  Completer<void>? gate;
  int calls = 0;

  @override
  Future<Either<Failure, List<OrderedItem>>> getOrderedItems(
    int orderId,
  ) async {
    calls++;
    await gate?.future;
    return items;
  }

  @override
  Future<Either<Failure, CatalogPage<OrderListEntry>>> getRunningOrders({
    required int page,
    int pageSize = ordersPageSize,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, CatalogPage<OrderListEntry>>> getPastOrders({
    required int page,
    int pageSize = ordersPageSize,
  }) => throw UnimplementedError();
}

/// An in-memory server cart. Items in [unavailable] are refused.
class _FakeCartRepository implements CartRepository {
  List<CartLine> lines = <CartLine>[];
  Set<int> unavailable = <int>{};
  Failure? getCartFailure;
  Failure? removeFailure;
  final List<String> log = <String>[];
  int _nextLineId = 100;

  Either<Failure, Cart> get _cart =>
      Right<Failure, Cart>(Cart(List<CartLine>.of(lines)));

  @override
  Future<Either<Failure, Cart>> getCart() async {
    log.add('get');
    final Failure? failure = getCartFailure;
    return failure == null ? _cart : Left<Failure, Cart>(failure);
  }

  @override
  Future<Either<Failure, Cart>> addItem({
    required int itemId,
    required double unitPrice,
    int quantity = 1,
  }) async {
    log.add('add $itemId x$quantity @$unitPrice');
    if (unavailable.contains(itemId)) {
      return const Left<Failure, Cart>(ForbiddenFailure());
    }
    lines.add(_line(_nextLineId++, itemId, quantity, storeId: 7));
    return _cart;
  }

  @override
  Future<Either<Failure, Cart>> updateQuantity({
    required int cartLineId,
    required int quantity,
  }) async {
    log.add('update $cartLineId to $quantity');
    lines = <CartLine>[
      for (final CartLine l in lines)
        l.id == cartLineId
            ? _line(l.id, l.itemId, quantity, storeId: l.storeId)
            : l,
    ];
    return _cart;
  }

  @override
  Future<Either<Failure, Cart>> removeLine(int cartLineId) async {
    log.add('remove $cartLineId');
    final Failure? failure = removeFailure;
    if (failure != null) return Left<Failure, Cart>(failure);
    lines.removeWhere((CartLine l) => l.id == cartLineId);
    return _cart;
  }
}

CartLine _line(int id, int itemId, int quantity, {int? storeId}) => CartLine(
  id: id,
  itemId: itemId,
  name: 'Item $itemId',
  unitPrice: 10,
  quantity: quantity,
  storeId: storeId,
);

const OrderListEntry _order = OrderListEntry(
  id: 9,
  status: OrderListStatus.delivered,
  storeId: 7,
);

void main() {
  late _FakeOrdersRepository orders;
  late _FakeCartRepository cart;
  late ReorderCubit cubit;

  setUp(() {
    orders = _FakeOrdersRepository();
    cart = _FakeCartRepository();
    cubit = ReorderCubit(ordersRepository: orders, cartRepository: cart);
  });

  tearDown(() => cubit.close());

  test('puts every line of the order in an empty cart', () async {
    await cubit.reorder(_order);

    expect(cubit.state, const ReorderSucceeded(9));
    expect(cart.log, <String>['get', 'add 10 x2 @20.0', 'add 11 x1 @5.0']);
  });

  test('raises the quantity of an item already in the cart', () async {
    cart.lines = <CartLine>[_line(1, 10, 1, storeId: 7)];

    await cubit.reorder(_order);

    expect(cart.log, contains('update 1 to 3'));
    expect(cart.log, isNot(contains('add 10 x2 @20.0')));
  });

  test('an item listed twice adds up in one cart line', () async {
    orders.items = const Right<Failure, List<OrderedItem>>(<OrderedItem>[
      OrderedItem(itemId: 10, quantity: 1, unitPrice: 20),
      OrderedItem(itemId: 10, quantity: 2, unitPrice: 20),
    ]);

    await cubit.reorder(_order);

    expect(cart.log, <String>['get', 'add 10 x1 @20.0', 'update 100 to 3']);
  });

  test('lines that are no longer sold are skipped and counted', () async {
    cart.unavailable = <int>{11};
    orders.items = const Right<Failure, List<OrderedItem>>(<OrderedItem>[
      OrderedItem(itemId: 10, quantity: 1, unitPrice: 20),
      OrderedItem(itemId: 11, quantity: 1, unitPrice: 5),
      OrderedItem(itemId: null, quantity: 1, unitPrice: 9),
    ]);

    await cubit.reorder(_order);

    expect(cubit.state, const ReorderSucceeded(9, skipped: 2));
  });

  test('fails when no line gets in', () async {
    cart.unavailable = <int>{10, 11};

    await cubit.reorder(_order);

    expect(cubit.state, const ReorderFailed(9, ForbiddenFailure()));
  });

  test('an order with nothing re-addable is unavailable', () async {
    orders.items = const Right<Failure, List<OrderedItem>>(<OrderedItem>[
      OrderedItem(itemId: null, quantity: 1, unitPrice: 9),
    ]);

    await cubit.reorder(_order);

    expect(cubit.state, const ReorderUnavailable(9));
    expect(cart.log, isEmpty);
  });

  test('a failed details call is reported, the cart untouched', () async {
    orders.items = const Left<Failure, List<OrderedItem>>(NetworkFailure());

    await cubit.reorder(_order);

    expect(cubit.state, const ReorderFailed(9, NetworkFailure()));
    expect(cart.log, isEmpty);
  });

  test('a cart that cannot be read is reported', () async {
    cart.getCartFailure = const NetworkFailure();

    await cubit.reorder(_order);

    expect(cubit.state, const ReorderFailed(9, NetworkFailure()));
  });

  test('the same order can be reordered again once done', () async {
    await cubit.reorder(_order);

    await cubit.reorder(_order);

    expect(cubit.state, const ReorderSucceeded(9));
    expect(orders.calls, 2);
    expect(cart.log, contains('update 100 to 4'));
  });

  test('a second tap while one is running sends nothing', () async {
    orders.gate = Completer<void>();
    final Future<void> first = cubit.reorder(_order);

    await cubit.reorder(_order);
    orders.gate!.complete();
    await first;

    expect(orders.calls, 1);
  });

  group('a cart from another store', () {
    setUp(() => cart.lines = <CartLine>[_line(1, 50, 1, storeId: 8)]);

    test('asks first and changes nothing meanwhile', () async {
      await cubit.reorder(_order);

      expect(cubit.state, const ReorderAwaitingConfirmation(9));
      expect(cart.log, <String>['get']);
    });

    test('once confirmed, is emptied and refilled', () async {
      await cubit.reorder(_order);

      await cubit.confirmReplace();

      expect(cubit.state, const ReorderSucceeded(9));
      expect(cart.lines.map((CartLine l) => l.itemId), <int>[10, 11]);
      expect(cart.log, contains('remove 1'));
    });

    test('a line already gone still counts as removed', () async {
      await cubit.reorder(_order);
      cart.removeFailure = const NotFoundFailure();

      await cubit.confirmReplace();

      expect(cubit.state, const ReorderSucceeded(9));
    });

    test('any other removal failure stops the reorder', () async {
      await cubit.reorder(_order);
      cart.removeFailure = const NetworkFailure();

      await cubit.confirmReplace();

      expect(cubit.state, const ReorderFailed(9, NetworkFailure()));
      expect(cart.log.where((String c) => c.startsWith('add')), isEmpty);
    });

    test('answering after the cubit closed does nothing', () async {
      await cubit.reorder(_order);
      await cubit.close();

      await cubit.confirmReplace();
      cubit.cancelReplace();

      expect(cart.log, <String>['get']);
    });

    test('declining leaves the cart as it was', () async {
      await cubit.reorder(_order);

      cubit.cancelReplace();

      expect(cubit.state, const ReorderIdle());
      expect(cart.lines.single.itemId, 50);
    });
  });

  test('the store is taken from the lines when the order lacks it', () async {
    cart.lines = <CartLine>[_line(1, 50, 1, storeId: 8)];

    await cubit.reorder(
      const OrderListEntry(id: 9, status: OrderListStatus.delivered),
    );

    expect(cubit.state, const ReorderAwaitingConfirmation(9));
  });
}
