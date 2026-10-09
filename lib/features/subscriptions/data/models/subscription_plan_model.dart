import '../../../../core/api/json_readers.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/subscription_plan.dart';

/// One entry of `GET /customer/subscription-plans` or
/// `GET /customer/c2c-parcels/subscription-plans` → `{ "data": [...] }`.
/// Only parcel plans carry the distance / weight limits.
class SubscriptionPlanModel extends SubscriptionPlan {
  const SubscriptionPlanModel({
    required super.id,
    required super.name,
    required super.deliveriesCount,
    required super.validityDays,
    required super.price,
    required super.currency,
    super.maxDistanceKm,
    super.maxWeightKg,
  });

  /// Null for an entry missing any field the card needs — a plan without a
  /// price or delivery count can't be offered.
  static SubscriptionPlanModel? tryFromJson(dynamic json) {
    if (json is! Map) return null;
    final int? id = jsonInt(json['id']);
    final String? name = jsonString(json['name']);
    final int? deliveries = jsonInt(json['deliveries_count']);
    final int? validity = jsonInt(json['validity_days']);
    // Decimal columns arrive as strings ("100.00").
    final double? price = jsonDouble(json['price']);
    if (id == null ||
        name == null ||
        deliveries == null ||
        validity == null ||
        price == null) {
      return null;
    }
    return SubscriptionPlanModel(
      id: id,
      name: name,
      deliveriesCount: deliveries,
      validityDays: validity,
      price: price,
      currency: jsonString(json['currency']) ?? 'SAR',
      maxDistanceKm: jsonDouble(json['max_distance_km']),
      maxWeightKg: jsonDouble(json['max_weight_kg']),
    );
  }

  /// Throws [ServerException] when the body has no `data` list.
  static List<SubscriptionPlanModel> listFromJson(dynamic json) {
    final dynamic data = json is Map ? json['data'] : null;
    if (data is! List) throw const ServerException();
    return data
        .map(SubscriptionPlanModel.tryFromJson)
        .whereType<SubscriptionPlanModel>()
        .toList(growable: false);
  }
}
