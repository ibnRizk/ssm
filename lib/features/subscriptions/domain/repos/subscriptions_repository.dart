import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/active_subscription.dart';
import '../entities/delivery_zone.dart';
import '../entities/subscription_plan.dart';

abstract class SubscriptionsRepository {
  Future<Either<Failure, List<DeliveryZone>>> getZones();

  /// Active plans in [zoneId] only.
  Future<Either<Failure, List<SubscriptionPlan>>> getPlans(int zoneId);

  /// `Right(null)` when the customer has no active subscription.
  Future<Either<Failure, ActiveSubscription?>> getCurrentSubscription();

  /// Creates an **unpaid, pending** subscription (HTTP 201). Online payment
  /// isn't integrated, so an admin activates it after payment. An unknown
  /// plan answers 404.
  Future<Either<Failure, Unit>> createPurchaseIntent(int planId);

  /// Door-to-door parcel plans in [zoneId] (plus plans valid in every
  /// zone). There's no purchase endpoint for these — an admin grants them.
  Future<Either<Failure, List<SubscriptionPlan>>> getParcelPlans(int zoneId);

  /// The customer's active parcel plans with their remaining deliveries;
  /// empty when there are none.
  Future<Either<Failure, List<ActiveSubscription>>> getParcelSubscriptions();
}
