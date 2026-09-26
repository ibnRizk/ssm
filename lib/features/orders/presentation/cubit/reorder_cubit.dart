import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../cart/domain/entities/cart.dart';
import '../../../cart/domain/repos/cart_repository.dart';
import '../../domain/entities/order_list_entry.dart';
import '../../domain/repos/orders_repository.dart';
import 'reorder_state.dart';

/// Tab-scoped (provided at the orders route). Puts a past order's lines
/// back in the server-side cart — there's no reorder endpoint. The cart
/// holds one store's items, so a cart from another store is only emptied
/// once the customer agrees. One reorder at a time.
///
/// Items go back as plain items: variations and add-ons aren't carried
/// over, and the server reprices everything when the order is placed.
///
/// Calls [CartRepository] directly, outside `CartCubit`'s queue. That's
/// safe only while no `CartCubit` is alive during a reorder: they live on
/// routes pushed over the tab shell (store details, cart, checkout), so the
/// Orders tab can't be reached with one open, and the cart this opens on
/// success loads a fresh one. Revisit if a cart ever lives inside a tab.
class ReorderCubit extends Cubit<ReorderState> {
  final OrdersRepository ordersRepository;
  final CartRepository cartRepository;

  ReorderCubit({required this.ordersRepository, required this.cartRepository})
    : super(const ReorderIdle());

  /// The lines waiting on [ReorderAwaitingConfirmation].
  List<OrderedItem> _pending = const <OrderedItem>[];

  bool get _busy =>
      state is ReorderInProgress || state is ReorderAwaitingConfirmation;

  Future<void> reorder(OrderListEntry order) async {
    if (_busy) return;
    emit(ReorderInProgress(order.id));

    final Either<Failure, List<OrderedItem>> lines = await ordersRepository
        .getOrderedItems(order.id);
    if (isClosed) return;
    final List<OrderedItem>? items = lines.fold((Failure failure) {
      emit(ReorderFailed(order.id, failure));
      return null;
    }, (List<OrderedItem> items) => items);
    if (items == null) return;
    if (!items.any(_addable)) {
      emit(ReorderUnavailable(order.id));
      return;
    }

    final Cart? cart = await _fetchCart(order.id);
    if (cart == null) return;
    final int? storeId =
        order.storeId ??
        items.map((OrderedItem i) => i.storeId).nonNulls.firstOrNull;
    if (cart.conflictsWithStore(storeId)) {
      _pending = items;
      emit(ReorderAwaitingConfirmation(order.id));
      return;
    }
    await _addAll(order.id, items, cart);
  }

  /// The customer agreed to empty the other store's cart. A line that's
  /// already gone counts as removed; any other failure stops the reorder.
  Future<void> confirmReplace() async {
    final ReorderState current = state;
    // The dialog may outlive the cubit, and emitting after close throws.
    if (isClosed || current is! ReorderAwaitingConfirmation) return;
    final int orderId = current.orderId;
    final List<OrderedItem> items = _pending;
    _pending = const <OrderedItem>[];
    emit(ReorderInProgress(orderId));

    // The cart may have changed while the customer was deciding.
    final Cart? cart = await _fetchCart(orderId);
    if (cart == null) return;
    for (final CartLine line in cart.lines) {
      final Either<Failure, Cart> removed = await cartRepository.removeLine(
        line.id,
      );
      if (isClosed) return;
      if (removed case Left<Failure, Cart>(
        :final Failure value,
      ) when value is! NotFoundFailure) {
        emit(ReorderFailed(orderId, value));
        return;
      }
    }
    await _addAll(orderId, items, Cart.empty);
  }

  void cancelReplace() {
    if (isClosed || state is! ReorderAwaitingConfirmation) return;
    _pending = const <OrderedItem>[];
    emit(const ReorderIdle());
  }

  /// Null (with [ReorderFailed] emitted) when the cart can't be read.
  Future<Cart?> _fetchCart(int orderId) async {
    final Either<Failure, Cart> result = await cartRepository.getCart();
    if (isClosed) return null;
    return result.fold((Failure failure) {
      emit(ReorderFailed(orderId, failure));
      return null;
    }, (Cart cart) => cart);
  }

  /// Adds each line — raising the quantity of an item already in the cart,
  /// since the cart holds one line per item. A line that fails is skipped;
  /// the reorder fails only when none got in.
  Future<void> _addAll(int orderId, List<OrderedItem> items, Cart cart) async {
    int added = 0;
    Failure? lastFailure;
    for (final OrderedItem item in items.where(_addable)) {
      final CartLine? line = cart.lineForItem(item.itemId!);
      final Either<Failure, Cart> result = await (line == null
          ? cartRepository.addItem(
              itemId: item.itemId!,
              unitPrice: item.unitPrice,
              quantity: item.quantity,
            )
          : cartRepository.updateQuantity(
              cartLineId: line.id,
              quantity: line.quantity + item.quantity,
            ));
      if (isClosed) return;
      result.fold((Failure failure) => lastFailure = failure, (Cart updated) {
        cart = updated;
        added++;
      });
    }
    // Only reached with at least one addable line, so a failure is known.
    if (added == 0) {
      emit(ReorderFailed(orderId, lastFailure ?? const ServerFailure()));
      return;
    }
    emit(ReorderSucceeded(orderId, skipped: items.length - added));
  }

  static bool _addable(OrderedItem item) => item.itemId != null;
}
