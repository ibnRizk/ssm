import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/store_promotion.dart';

sealed class PromotionsState extends Equatable {
  const PromotionsState();

  @override
  List<Object?> get props => [];
}

final class PromotionsInitial extends PromotionsState {
  const PromotionsInitial();
}

final class PromotionsLoading extends PromotionsState {
  const PromotionsLoading();
}

/// Never empty — an empty answer is [PromotionsEmpty].
final class PromotionsLoaded extends PromotionsState {
  final List<StorePromotion> promotions;

  const PromotionsLoaded(this.promotions);

  @override
  List<Object?> get props => [promotions];
}

/// The zone has no featured promotions right now.
final class PromotionsEmpty extends PromotionsState {
  const PromotionsEmpty();
}

final class PromotionsError extends PromotionsState {
  final Failure failure;

  const PromotionsError(this.failure);

  @override
  List<Object?> get props => [failure];
}
