import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../domain/entities/active_subscription.dart';
import '../models/active_subscription_model.dart';
import '../models/delivery_zone_model.dart';
import '../models/parcel_subscription_model.dart';
import '../models/subscription_plan_model.dart';

abstract class SubscriptionsRemoteDataSource {
  Future<List<DeliveryZoneModel>> getZones();

  Future<List<SubscriptionPlanModel>> getPlans(int zoneId);

  Future<ActiveSubscriptionModel?> getCurrentSubscription();

  Future<void> createPurchaseIntent(int planId);

  Future<List<SubscriptionPlanModel>> getParcelPlans(int zoneId);

  Future<List<ActiveSubscription>> getParcelSubscriptions();
}

class SubscriptionsRemoteDataSourceImpl
    implements SubscriptionsRemoteDataSource {
  final DioConsumer consumer;

  const SubscriptionsRemoteDataSourceImpl({required this.consumer});

  @override
  Future<List<DeliveryZoneModel>> getZones() async =>
      DeliveryZoneModel.listFromJson(await consumer.get(ApiEndpoints.zoneList));

  @override
  Future<List<SubscriptionPlanModel>> getPlans(int zoneId) async =>
      SubscriptionPlanModel.listFromJson(
        await consumer.get(
          ApiEndpoints.subscriptionPlans,
          queryParameters: <String, dynamic>{'zone_id': zoneId},
        ),
      );

  @override
  Future<ActiveSubscriptionModel?> getCurrentSubscription() async =>
      ActiveSubscriptionModel.fromJson(
        await consumer.get(ApiEndpoints.currentSubscription),
      );

  /// Answers 201 with the pending, unpaid subscription. Dio treats any 2xx
  /// as success; the body isn't needed, since a pending intent is never the
  /// "current" subscription.
  @override
  Future<void> createPurchaseIntent(int planId) => consumer.post(
    ApiEndpoints.subscriptionPurchaseIntent,
    body: <String, dynamic>{'plan_id': planId},
  );

  @override
  Future<List<SubscriptionPlanModel>> getParcelPlans(int zoneId) async =>
      SubscriptionPlanModel.listFromJson(
        await consumer.get(
          ApiEndpoints.c2cParcelSubscriptionPlans,
          queryParameters: <String, dynamic>{'zone_id': zoneId},
        ),
      );

  @override
  Future<List<ActiveSubscription>> getParcelSubscriptions() async =>
      ParcelSubscriptionModel.listFromJson(
        await consumer.get(ApiEndpoints.c2cParcelSubscriptions),
      );
}
