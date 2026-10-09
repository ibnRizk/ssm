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

/// The two independent kinds of plan the screen offers.
enum SubscriptionProduct {
  /// Store-order delivery plans.
  delivery,

  /// Door-to-door (customer-to-customer) parcel plans.
  parcels,
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

  /// Which kind of plan is on screen.
  final SubscriptionProduct product;

  /// Parcel plans of [selectedZoneId]. Null until the parcels side is first
  /// opened — it's only fetched for customers who look at it.
  final PlansStatus? parcelPlans;

  /// Active parcel plans and their balances. Empty when there are none, or
  /// they couldn't be fetched.
  final List<ActiveSubscription> parcelSubscriptions;

  const SubscriptionsLoaded({
    required this.zones,
    required this.selectedZoneId,
    required this.plans,
    this.current,
    this.purchase = const PurchaseIdle(),
    this.product = SubscriptionProduct.delivery,
    this.parcelPlans,
    this.parcelSubscriptions = const <ActiveSubscription>[],
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
    SubscriptionProduct? product,
    PlansStatus? parcelPlans,
    List<ActiveSubscription>? parcelSubscriptions,
  }) => SubscriptionsLoaded(
    zones: zones,
    selectedZoneId: selectedZoneId ?? this.selectedZoneId,
    plans: plans ?? this.plans,
    current: current,
    purchase: purchase ?? this.purchase,
    product: product ?? this.product,
    parcelPlans: parcelPlans ?? this.parcelPlans,
    parcelSubscriptions: parcelSubscriptions ?? this.parcelSubscriptions,
  );

  @override
  List<Object?> get props => [
    zones,
    selectedZoneId,
    plans,
    current,
    purchase,
    product,
    parcelPlans,
    parcelSubscriptions,
  ];
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
