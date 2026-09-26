import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/active_subscription.dart';
import '../../domain/entities/delivery_zone.dart';
import '../../domain/entities/subscription_plan.dart';

sealed class SubscriptionsState extends Equatable {
  const SubscriptionsState();

  @override
  List<Object?> get props => [];
}

final class SubscriptionsInitial extends SubscriptionsState {
  const SubscriptionsInitial();
}

final class SubscriptionsLoading extends SubscriptionsState {
  const SubscriptionsLoading();
}

/// The zones couldn't be fetched — nothing else on the screen works
/// without them.
final class SubscriptionsError extends SubscriptionsState {
  final Failure failure;

  const SubscriptionsError(this.failure);

  @override
  List<Object?> get props => [failure];
}

final class SubscriptionsLoaded extends SubscriptionsState {
  final List<DeliveryZone> zones;

  /// Null only when the backend has no zones at all.
  final int? selectedZoneId;

  /// Plans of [selectedZoneId]; loads independently of the zones.
  final PlansStatus plans;

  /// Null when there's no active subscription, or it couldn't be fetched —
  /// either way the banner is hidden.
  final ActiveSubscription? current;

  final PurchaseStatus purchase;

  const SubscriptionsLoaded({
    required this.zones,
    required this.selectedZoneId,
    required this.plans,
    this.current,
    this.purchase = const PurchaseIdle(),
  });

  DeliveryZone? get selectedZone {
    for (final DeliveryZone zone in zones) {
      if (zone.id == selectedZoneId) return zone;
    }
    return null;
  }

  SubscriptionsLoaded copyWith({
    int? selectedZoneId,
    PlansStatus? plans,
    PurchaseStatus? purchase,
  }) => SubscriptionsLoaded(
    zones: zones,
    selectedZoneId: selectedZoneId ?? this.selectedZoneId,
    plans: plans ?? this.plans,
    current: current,
    purchase: purchase ?? this.purchase,
  );

  @override
  List<Object?> get props => [zones, selectedZoneId, plans, current, purchase];
}

// --- Plans of the selected zone ---

sealed class PlansStatus extends Equatable {
  const PlansStatus();

  @override
  List<Object?> get props => [];
}

final class PlansLoading extends PlansStatus {
  const PlansLoading();
}

final class PlansLoaded extends PlansStatus {
  final List<SubscriptionPlan> plans;

  /// The plan to highlight — see [SubscriptionPlan.bestValueId].
  final int? bestValueId;

  const PlansLoaded(this.plans, {this.bestValueId});

  @override
  List<Object?> get props => [plans, bestValueId];
}

final class PlansError extends PlansStatus {
  final Failure failure;

  const PlansError(this.failure);

  @override
  List<Object?> get props => [failure];
}

// --- Purchase intent ---

sealed class PurchaseStatus extends Equatable {
  const PurchaseStatus();

  @override
  List<Object?> get props => [];
}

final class PurchaseIdle extends PurchaseStatus {
  const PurchaseIdle();
}

final class PurchaseInProgress extends PurchaseStatus {
  final int planId;

  const PurchaseInProgress(this.planId);

  @override
  List<Object?> get props => [planId];
}

/// HTTP 201: the subscription exists but is unpaid and pending — an admin
/// activates it after payment.
final class PurchasePendingApproval extends PurchaseStatus {
  final int planId;

  const PurchasePendingApproval(this.planId);

  @override
  List<Object?> get props => [planId];
}

final class PurchaseFailed extends PurchaseStatus {
  final Failure failure;

  const PurchaseFailed(this.failure);

  @override
  List<Object?> get props => [failure];
}
