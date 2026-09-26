import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_base/core/error/failures.dart';
import 'package:flutter_base/features/cart/domain/entities/cart.dart';
import 'package:flutter_base/features/cart/domain/repos/cart_repository.dart';
import 'package:flutter_base/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:flutter_base/features/cart/presentation/cubit/cart_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// One call the fake received; the test answers it, so ordering is explicit.
class _Call {
  final String method;
  final Map<String, Object?> args;
  final Completer<Either<Failure, Cart>> completer = Completer();

  _Call(this.method, this.args);

  void answer(Cart cart) => completer.complete(Right<Failure, Cart>(cart));

  void fail(Failure failure) =>
      completer.complete(Left<Failure, Cart>(failure));
}

class _FakeCartRepository implements CartRepository {
  final List<_Call> calls = <_Call>[];

  Future<Either<Failure, Cart>> _record(
    String method,
    Map<String, Object?> args,
  ) {
    final _Call call = _Call(method, args);
    calls.add(call);
    return call.completer.future;
  }

  @override
  Future<Either<Failure, Cart>> getCart() =>
      _record('getCart', const <String, Object?>{});

  @override
  Future<Either<Failure, Cart>> addItem({
    required int itemId,
    required double unitPrice,
    int quantity = 1,
  }) => _record('addItem', <String, Object?>{
    'itemId': itemId,
    'unitPrice': unitPrice,
  });

  @override
  Future<Either<Failure, Cart>> updateQuantity({
    required int cartLineId,
    required int quantity,
  }) => _record('updateQuantity', <String, Object?>{
    'cartLineId': cartLineId,
    'quantity': quantity,
  });

  @override
  Future<Either<Failure, Cart>> removeLine(int cartLineId) =>
      _record('removeLine', <String, Object?>{'cartLineId': cartLineId});
}

CartLine _line({
  int id = 1,
  int itemId = 10,
  int quantity = 1,
  int storeId = 7,
}) => CartLine(
  id: id,
  itemId: itemId,
  name: 'Item $itemId',
  unitPrice: 10,
  quantity: quantity,
  storeId: storeId,
);

const CartItemRequest _burger = CartItemRequest(
  itemId: 10,
  storeId: 7,
  unitPrice: 10,
);

/// Lets queued work reach the fake before the test inspects its calls.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late _FakeCartRepository repository;
  late CartCubit cubit;

  /// Every notice emitted — a notice lives for one state, so the final
  /// state no longer carries it.
  late List<CartNotice> notices;
  late StreamSubscription<CartState> subscription;

  setUp(() {
    repository = _FakeCartRepository();
    cubit = CartCubit(repository: repository);
    notices = <CartNotice>[];
    subscription = cubit.stream.listen((CartState state) {
      if (state case CartLoaded(:final CartNotice notice)) notices.add(notice);
    });
  });

  tearDown(() async {
    await subscription.cancel();
    await cubit.close();
  });

  Future<void> loadWith(Cart cart) async {
    final Future<void> load = cubit.load();
    await _settle();
    repository.calls.last.answer(cart);
    await load;
  }

  test('loads the cart', () async {
    final Future<void> load = cubit.load();
    await _settle();
    expect(cubit.state, const CartLoading());

    repository.calls.single.answer(Cart(<CartLine>[_line()]));
    await load;

    expect((cubit.state as CartLoaded).cart.itemCount, 1);
  });

  test('a failed first load is an error', () async {
    final Future<void> load = cubit.load();
    await _settle();
    repository.calls.single.fail(const NetworkFailure());
    await load;

    expect(cubit.state, const CartError(NetworkFailure()));
  });

  test('adding a new item adds a line at its price', () async {
    await loadWith(Cart.empty);

    final Future<void> add = cubit.addItem(_burger);
    await _settle();
    expect((cubit.state as CartLoaded).addingItemIds, <int>{10});
    expect(repository.calls.last.method, 'addItem');
    expect(repository.calls.last.args, <String, Object?>{
      'itemId': 10,
      'unitPrice': 10.0,
    });

    repository.calls.last.answer(Cart(<CartLine>[_line()]));
    await add;

    expect((cubit.state as CartLoaded).cart.itemCount, 1);
    expect((cubit.state as CartLoaded).addingItemIds, isEmpty);
  });

  test('adding an item already in the cart raises its quantity', () async {
    await loadWith(Cart(<CartLine>[_line(id: 5, quantity: 2)]));

    final Future<void> add = cubit.addItem(_burger);
    await _settle();

    expect(repository.calls.last.method, 'updateQuantity');
    expect(repository.calls.last.args, <String, Object?>{
      'cartLineId': 5,
      'quantity': 3,
    });
    repository.calls.last.answer(Cart(<CartLine>[_line(id: 5, quantity: 3)]));
    await add;
  });

  test('an item from another store asks first and changes nothing', () async {
    await loadWith(Cart(<CartLine>[_line(storeId: 8)]));

    await cubit.addItem(_burger);

    expect(repository.calls, hasLength(1), reason: 'only the load');
    await _settle(); // stream events arrive asynchronously
    expect(notices, <CartNotice>[const CartStoreConflict(1, _burger)]);
  });

  test('replacing the cart removes every line, then adds the item', () async {
    await loadWith(
      Cart(<CartLine>[
        _line(id: 1, itemId: 30, storeId: 8),
        _line(id: 2, itemId: 40, storeId: 8),
      ]),
    );

    final Future<void> replace = cubit.replaceCartWith(_burger);
    await _settle();
    expect(repository.calls.last.args, <String, Object?>{'cartLineId': 1});
    repository.calls.last.answer(
      Cart(<CartLine>[_line(id: 2, itemId: 40, storeId: 8)]),
    );
    await _settle();
    expect(repository.calls.last.args, <String, Object?>{'cartLineId': 2});
    repository.calls.last.answer(Cart.empty);
    await _settle();
    expect(repository.calls.last.method, 'addItem');
    repository.calls.last.answer(Cart(<CartLine>[_line()]));
    await replace;

    expect((cubit.state as CartLoaded).cart.lines.single.storeId, 7);
  });

  test('decrementing the last unit removes the line', () async {
    final CartLine line = _line(id: 5);
    await loadWith(Cart(<CartLine>[line]));

    final Future<void> decrement = cubit.decrement(line);
    await _settle();

    expect(repository.calls.last.method, 'removeLine');
    repository.calls.last.answer(Cart.empty);
    await decrement;
    expect((cubit.state as CartLoaded).cart.isEmpty, isTrue);
  });

  test('taps on a line with a change in flight are ignored', () async {
    final CartLine line = _line(id: 5, quantity: 2);
    await loadWith(Cart(<CartLine>[line]));

    final Future<void> first = cubit.increment(line);
    await cubit.increment(line);
    await _settle();

    expect(
      repository.calls.where((_Call c) => c.method == 'updateQuantity'),
      hasLength(1),
    );
    expect((cubit.state as CartLoaded).busyLineIds, <int>{5});
    repository.calls.last.answer(Cart(<CartLine>[_line(id: 5, quantity: 3)]));
    await first;
    expect((cubit.state as CartLoaded).busyLineIds, isEmpty);
  });

  test('changes run one at a time, each from the latest cart', () async {
    final CartLine a = _line(id: 1, itemId: 10);
    final CartLine b = _line(id: 2, itemId: 20);
    await loadWith(Cart(<CartLine>[a, b]));

    final Future<void> first = cubit.increment(a);
    final Future<void> second = cubit.increment(b);
    await _settle();
    expect(repository.calls, hasLength(2), reason: 'b waits for a');

    repository.calls.last.answer(
      Cart(<CartLine>[_line(id: 1, itemId: 10, quantity: 2), b]),
    );
    await first;
    await _settle();
    expect(repository.calls.last.args, <String, Object?>{
      'cartLineId': 2,
      'quantity': 2,
    });
    repository.calls.last.answer(
      Cart(<CartLine>[
        _line(id: 1, itemId: 10, quantity: 2),
        _line(id: 2, itemId: 20, quantity: 2),
      ]),
    );
    await second;

    expect((cubit.state as CartLoaded).cart.itemCount, 4);
  });

  test('a line that is already gone re-syncs the cart', () async {
    final CartLine line = _line(id: 5);
    await loadWith(Cart(<CartLine>[line]));

    final Future<void> increment = cubit.increment(line);
    await _settle();
    repository.calls.last.fail(const NotFoundFailure());
    await _settle();
    expect(repository.calls.last.method, 'getCart');
    repository.calls.last.answer(Cart.empty);
    await increment;

    expect((cubit.state as CartLoaded).cart.isEmpty, isTrue);
    await _settle(); // stream events arrive asynchronously
    expect(notices.single, isA<CartLineGone>());
  });

  test('a gone line whose re-sync fails reports that failure', () async {
    final CartLine line = _line(id: 5);
    await loadWith(Cart(<CartLine>[line]));

    final Future<void> increment = cubit.increment(line);
    await _settle();
    repository.calls.last.fail(const NotFoundFailure());
    await _settle();
    repository.calls.last.fail(const NetworkFailure());
    await increment;
    await _settle();

    expect(notices, <CartNotice>[const CartActionFailed(1, NetworkFailure())]);
  });

  test('a failed refresh keeps the cart and says so', () async {
    await loadWith(Cart(<CartLine>[_line()]));

    final Future<void> refresh = cubit.load();
    await _settle();
    repository.calls.last.fail(const NetworkFailure());
    await refresh;
    await _settle();

    expect((cubit.state as CartLoaded).cart.itemCount, 1);
    expect(notices, <CartNotice>[const CartActionFailed(1, NetworkFailure())]);
  });

  test('replacing skips a line that is already gone', () async {
    await loadWith(Cart(<CartLine>[_line(id: 1, itemId: 30, storeId: 8)]));

    final Future<void> replace = cubit.replaceCartWith(_burger);
    await _settle();
    repository.calls.last.fail(const NotFoundFailure());
    await _settle();
    expect(repository.calls.last.method, 'getCart');
    repository.calls.last.answer(Cart.empty);
    await _settle();
    expect(repository.calls.last.method, 'addItem');
    repository.calls.last.answer(Cart(<CartLine>[_line()]));
    await replace;
    await _settle();

    expect((cubit.state as CartLoaded).cart.lines.single.storeId, 7);
    expect(notices, isEmpty);
  });

  test('a failed change keeps the cart and reports the failure', () async {
    final CartLine line = _line(id: 5);
    await loadWith(Cart(<CartLine>[line]));

    final Future<void> increment = cubit.increment(line);
    await _settle();
    repository.calls.last.fail(const NetworkFailure());
    await increment;

    expect((cubit.state as CartLoaded).cart.lines.single, line);
    await _settle(); // stream events arrive asynchronously
    expect(notices, <CartNotice>[const CartActionFailed(1, NetworkFailure())]);
  });

  test('the same failure twice is two distinct notices', () {
    expect(
      const CartActionFailed(1, NetworkFailure()),
      isNot(const CartActionFailed(2, NetworkFailure())),
    );
  });

  test('a change that throws does not block later ones', () async {
    final CartLine line = _line(id: 5);
    await loadWith(Cart(<CartLine>[line]));

    final Future<void> broken = cubit.increment(line);
    await _settle();
    repository.calls.last.completer.completeError(StateError('boom'));
    await expectLater(broken, throwsStateError);
    expect((cubit.state as CartLoaded).busyLineIds, isEmpty);

    unawaited(cubit.load());
    await _settle();
    expect(repository.calls.last.method, 'getCart');
  });
}
