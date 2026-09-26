import 'package:dartz/dartz.dart';

import '../../../../core/api/safe_api_call.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/active_subscription.dart';
import '../../domain/entities/delivery_zone.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/repos/subscriptions_repository.dart';
import '../datasources/subscriptions_remote_data_source.dart';

class SubscriptionsRepositoryImpl implements SubscriptionsRepository {
  final SubscriptionsRemoteDataSource remote;

  const SubscriptionsRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, List<DeliveryZone>>> getZones() =>
      safeApiCall(remote.getZones);

  @override
  Future<Either<Failure, List<SubscriptionPlan>>> getPlans(int zoneId) =>
      safeApiCall(() => remote.getPlans(zoneId));

  @override
  Future<Either<Failure, ActiveSubscription?>> getCurrentSubscription() =>
      safeApiCall(remote.getCurrentSubscription);

  @override
  Future<Either<Failure, Unit>> createPurchaseIntent(int planId) =>
      safeApiCall(() async {
        await remote.createPurchaseIntent(planId);
        return unit;
      });
}
