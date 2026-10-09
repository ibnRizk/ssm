import 'package:equatable/equatable.dart';

/// A prepaid bundle of deliveries in one zone.
class SubscriptionPlan extends Equatable {
  final int id;
  final String name;
  final int deliveriesCount;
  final int validityDays;
  final double price;

  /// ISO 4217 code as sent by the backend, e.g. `SAR`.
  final String currency;

  /// Parcel plans only: the largest distance / weight a parcel may have to
  /// be covered. Null when the plan sets no such limit.
  final double? maxDistanceKm;
  final double? maxWeightKg;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.deliveriesCount,
    required this.validityDays,
    required this.price,
    required this.currency,
    this.maxDistanceKm,
    this.maxWeightKg,
  });

  /// The plan to highlight as "best value": the highest tier — most
  /// deliveries, then highest price. Chosen by data rather than by name
  /// ("Golden"), which admins can rename or translate. Null for fewer than
  /// two plans, where there's nothing to compare.
  static int? bestValueId(List<SubscriptionPlan> plans) {
    if (plans.length < 2) return null;
    SubscriptionPlan best = plans.first;
    for (final SubscriptionPlan plan in plans.skip(1)) {
      final bool moreDeliveries = plan.deliveriesCount > best.deliveriesCount;
      final bool sameButPricier =
          plan.deliveriesCount == best.deliveriesCount &&
          plan.price > best.price;
      if (moreDeliveries || sameButPricier) best = plan;
    }
    return best.id;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    deliveriesCount,
    validityDays,
    price,
    currency,
    maxDistanceKm,
    maxWeightKg,
  ];
}
