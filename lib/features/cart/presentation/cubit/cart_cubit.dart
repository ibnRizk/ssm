import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/cart.dart';
import '../../domain/repos/cart_repository.dart';
import 'cart_state.dart';

/// Mirrors the customer's server-side cart. Screen-scoped: created by the
/// store-details route and handed to Cart and Checkout through `extra`, so
/// those screens show — and change — the same instance.
///
/// Every server call runs through one queue. Each answers with the whole
/// cart, so running them one at a time makes the last answer the truth,
/// instead of an older snapshot overwriting a newer one. Decisions that
/// depend on the cart (merge into an existing line? another store?) are
/// made inside the queue, against the cart as it is by then.
class CartCubit extends Cubit<CartState> {
  final CartRepository repository;

  CartCubit({required this.repository}) : super(const CartInitial());

  Future<void> _queue = Future<void>.value();
  int _noticeSeq = 0;

  /// The source of truth for what's in flight; mirrored into [CartLoaded].
  final Set<int> _busyLineIds = <int>{};
  final Set<int> _addingItemIds = <int>{};

  /// The caller's future still reports [task]'s error, but the queue itself
  /// swallows it — one failed task must not block every later one.
  Future<void> _serial(Future<void> Function() task) {
    final Future<void> next = _queue.then((_) => isClosed ? null : task());
    _queue = next.catchError((Object _) {});
    return next;
  }

  /// (Re)fetches the cart. A refresh keeps the cart visible, and through a
  /// failure.
  Future<void> load() => _serial(() async {
    final bool refreshing = state is CartLoaded;
    if (!refreshing) emit(const CartLoading());
    final Either<Failure, Cart> result = await repository.getCart();
    if (isClosed) return;
    result.fold((Failure failure) {
      if (!refreshing) emit(CartError(failure));
    }, _emitCart);
  });

  /// Adds one unit of an item. An item already in the cart gets its
  /// quantity raised instead of a second line. An item from another store
  /// raises [CartStoreConflict] and changes nothing.
  Future<void> addItem(CartItemRequest request) async {
    if (!_addingItemIds.add(request.itemId)) return;
    _publish();
    try {
      await _serial(() async {
        final Cart cart = _cart;
        if (cart.conflictsWithStore(request.storeId)) {
          _notify((int seq) => CartStoreConflict(seq, request));
          return;
        }
        final CartLine? line = cart.lineForItem(request.itemId);
        await _apply(
          line == null
              ? repository.addItem(
                  itemId: request.itemId,
                  unitPrice: request.unitPrice,
                )
              : repository.updateQuantity(
                  cartLineId: line.id,
                  quantity: line.quantity + 1,
                ),
        );
      });
    } finally {
      _addingItemIds.remove(request.itemId);
      _publish();
    }
  }

  /// Empties the cart, then adds [request] — the customer's answer to a
  /// [CartStoreConflict]. Stops at the first failed step.
  Future<void> replaceCartWith(CartItemRequest request) async {
    if (!_addingItemIds.add(request.itemId)) return;
    _publish();
    try {
      await _serial(() async {
        for (final CartLine line in _cart.lines) {
          if (!await _apply(repository.removeLine(line.id))) return;
        }
        await _apply(
          repository.addItem(
            itemId: request.itemId,
            unitPrice: request.unitPrice,
          ),
        );
      });
    } finally {
      _addingItemIds.remove(request.itemId);
      _publish();
    }
  }

  Future<void> increment(CartLine line) =>
      _changeLine(line.id, (int quantity) => quantity + 1);

  /// Down to zero removes the line.
  Future<void> decrement(CartLine line) =>
      _changeLine(line.id, (int quantity) => quantity - 1);

  Future<void> remove(CartLine line) => _changeLine(line.id, (_) => 0);

  /// Ignored while that line already has a change in flight. The new
  /// quantity is computed from the line as it is when the call runs.
  Future<void> _changeLine(int lineId, int Function(int) quantityOf) async {
    if (!_busyLineIds.add(lineId)) return;
    _publish();
    try {
      await _serial(() async {
        final CartLine? line = _cart.lines
            .where((CartLine l) => l.id == lineId)
            .firstOrNull;
        if (line == null) return;
        final int quantity = quantityOf(line.quantity);
        await _apply(
          quantity < 1
              ? repository.removeLine(line.id)
              : repository.updateQuantity(
                  cartLineId: line.id,
                  quantity: quantity,
                ),
        );
      });
    } finally {
      _busyLineIds.remove(lineId);
      _publish();
    }
  }

  /// Applies a change's answer; returns whether it went through. A 404
  /// means the line was already gone, so the cart is re-fetched to stop
  /// showing it.
  Future<bool> _apply(Future<Either<Failure, Cart>> call) async {
    final Either<Failure, Cart> result = await call;
    if (isClosed) return false;
    final Failure? failure = result.fold((Failure f) => f, (Cart cart) {
      _emitCart(cart);
      return null;
    });
    if (failure == null) return true;

    if (failure is NotFoundFailure) {
      final Either<Failure, Cart> fresh = await repository.getCart();
      if (isClosed) return false;
      fresh.fold((_) {}, _emitCart);
      _notify(CartLineGone.new);
    } else {
      _notify((int seq) => CartActionFailed(seq, failure));
    }
    return false;
  }

  Cart get _cart {
    final CartState current = state;
    return current is CartLoaded ? current.cart : Cart.empty;
  }

  void _emitCart(Cart cart) {
    if (isClosed) return;
    emit(_loaded(cart));
  }

  /// Mirrors the in-flight sets into the state, once there's a cart to
  /// show them against — a still-loading cart stays loading.
  void _publish() {
    final CartState current = state;
    if (isClosed || current is! CartLoaded) return;
    emit(_loaded(current.cart));
  }

  void _notify(CartNotice Function(int seq) notice) {
    if (isClosed) return;
    emit(_loaded(_cart, notice: notice(++_noticeSeq)));
  }

  CartLoaded _loaded(Cart cart, {CartNotice? notice}) => CartLoaded(
    cart,
    busyLineIds: Set<int>.unmodifiable(_busyLineIds),
    addingItemIds: Set<int>.unmodifiable(_addingItemIds),
    notice: notice,
  );
}
