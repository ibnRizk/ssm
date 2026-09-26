import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/cart.dart';

sealed class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

final class CartInitial extends CartState {
  const CartInitial();
}

final class CartLoading extends CartState {
  const CartLoading();
}

/// The cart couldn't be fetched.
final class CartError extends CartState {
  final Failure failure;

  const CartError(this.failure);

  @override
  List<Object?> get props => [failure];
}

final class CartLoaded extends CartState {
  final Cart cart;

  /// Lines with a change in flight — their buttons are disabled meanwhile.
  final Set<int> busyLineIds;

  /// Items being added from a store's menu.
  final Set<int> addingItemIds;

  /// One-shot feedback for the screen to show; see [CartNotice]. Any later
  /// state clears it.
  final CartNotice? notice;

  const CartLoaded(
    this.cart, {
    this.busyLineIds = const <int>{},
    this.addingItemIds = const <int>{},
    this.notice,
  });

  @override
  List<Object?> get props => [cart, busyLineIds, addingItemIds, notice];
}

/// An item to add, as the store's menu shows it.
class CartItemRequest extends Equatable {
  final int itemId;

  /// Required, so every add goes through the single-store check.
  final int storeId;
  final double unitPrice;

  const CartItemRequest({
    required this.itemId,
    required this.storeId,
    required this.unitPrice,
  });

  @override
  List<Object?> get props => [itemId, storeId, unitPrice];
}

/// Feedback that isn't part of the cart itself. [seq] makes each notice
/// distinct, so the same failure twice in a row is still shown twice.
sealed class CartNotice extends Equatable {
  final int seq;

  const CartNotice(this.seq);

  @override
  List<Object?> get props => [seq];
}

final class CartActionFailed extends CartNotice {
  final Failure failure;

  const CartActionFailed(super.seq, this.failure);

  @override
  List<Object?> get props => [seq, failure];
}

/// A line was already gone server-side (404); the cart was re-synced.
final class CartLineGone extends CartNotice {
  const CartLineGone(super.seq);
}

/// [request] is from another store than the cart's items — ask before
/// replacing the cart with it (see `CartCubit.replaceCartWith`).
final class CartStoreConflict extends CartNotice {
  final CartItemRequest request;

  const CartStoreConflict(super.seq, this.request);

  @override
  List<Object?> get props => [seq, request];
}
