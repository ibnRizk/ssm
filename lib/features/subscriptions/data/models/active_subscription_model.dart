import '../../../../core/api/json_readers.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/active_subscription.dart';

/// `GET /customer/subscriptions/current` → `{ "data": { deliveries_total,
/// deliveries_used, deliveries_remaining, expires_at, … } }` or
/// `{ "data": null }`.
class ActiveSubscriptionModel extends ActiveSubscription {
  const ActiveSubscriptionModel({
    required super.id,
    required super.deliveriesTotal,
    required super.deliveriesRemaining,
    super.expiresAt,
    super.planName,
  });

  /// Null when there's no active subscription. Throws [ServerException]
  /// when the body has no `data` key, or a subscription lacks its counts.
  static ActiveSubscriptionModel? fromJson(dynamic json) {
    if (json is! Map || !json.containsKey('data')) {
      throw const ServerException();
    }
    final dynamic data = json['data'];
    if (data == null) return null;
    if (data is! Map) throw const ServerException();

    final int? id = jsonInt(data['id']);
    final int? total = jsonInt(data['deliveries_total']);
    final int? remaining = jsonInt(data['deliveries_remaining']);
    if (id == null || total == null || remaining == null) {
      throw const ServerException();
    }
    final dynamic plan = data['plan'];
    return ActiveSubscriptionModel(
      id: id,
      deliveriesTotal: total,
      deliveriesRemaining: remaining,
      expiresAt: DateTime.tryParse(jsonString(data['expires_at']) ?? ''),
      planName: plan is Map ? jsonString(plan['name']) : null,
    );
  }
}
