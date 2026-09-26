import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/loyalty_history.dart';
import '../../domain/entities/loyalty_progress.dart';

sealed class LoyaltyState extends Equatable {
  const LoyaltyState();

  @override
  List<Object?> get props => [];
}

final class LoyaltyInitial extends LoyaltyState {
  const LoyaltyInitial();
}

final class LoyaltyLoading extends LoyaltyState {
  const LoyaltyLoading();
}

final class LoyaltyLoaded extends LoyaltyState {
  final LoyaltyProgress progress;

  /// Null when only the history call failed — the progress is still worth
  /// showing, and the "latest orders" row is hidden.
  final LoyaltyHistory? history;

  const LoyaltyLoaded({required this.progress, this.history});

  @override
  List<Object?> get props => [progress, history];
}

final class LoyaltyError extends LoyaltyState {
  final Failure failure;

  const LoyaltyError(this.failure);

  @override
  List<Object?> get props => [failure];
}
