import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';

sealed class ReorderState extends Equatable {
  const ReorderState();

  @override
  List<Object?> get props => [];
}

final class ReorderIdle extends ReorderState {
  const ReorderIdle();
}

final class ReorderInProgress extends ReorderState {
  final int orderId;

  const ReorderInProgress(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

/// The cart holds another store's items — ask before emptying it (see
/// `ReorderCubit.confirmReplace` / `cancelReplace`).
final class ReorderAwaitingConfirmation extends ReorderState {
  final int orderId;

  const ReorderAwaitingConfirmation(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

/// At least one line is in the cart. [skipped] lines couldn't be added
/// (no longer sold, or not a plain store item).
final class ReorderSucceeded extends ReorderState {
  final int orderId;
  final int skipped;

  const ReorderSucceeded(this.orderId, {this.skipped = 0});

  @override
  List<Object?> get props => [orderId, skipped];
}

/// Nothing in the order can be added any more.
final class ReorderUnavailable extends ReorderState {
  final int orderId;

  const ReorderUnavailable(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

final class ReorderFailed extends ReorderState {
  final int orderId;
  final Failure failure;

  const ReorderFailed(this.orderId, this.failure);

  @override
  List<Object?> get props => [orderId, failure];
}
