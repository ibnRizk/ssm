import '../../../../core/api/json_readers.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/c2c_parcel_quote.dart';

/// `POST /customer/c2c-parcels/quote` → `{ "data": { distance_km,
/// total_fee, currency, estimated_delivery_minutes, quote_token,
/// quote_expires_at, … } }`, plus `base_total_fee`, `subscription_discount`
/// and `applied_subscription` once a parcel plan applies.
///
/// A body without the `data` wrapper is read too, and amounts may arrive as
/// decimal strings.
class C2cParcelQuoteModel extends C2cParcelQuote {
  const C2cParcelQuoteModel({
    super.quoteToken,
    required super.baseTotalFee,
    required super.subscriptionDiscount,
    required super.totalFee,
    required super.currency,
    super.distanceKm,
    super.estimatedDeliveryMinutes,
    super.expiresAt,
    super.appliedSubscription,
  });

  /// Throws [ServerException] when there's no `total_fee` — a quote without
  /// a price can't be shown.
  factory C2cParcelQuoteModel.fromJson(dynamic json) {
    final dynamic data = json is Map && json['data'] is Map
        ? json['data']
        : json;
    if (data is! Map) throw const ServerException();

    final double? total = jsonDouble(data['total_fee']);
    if (total == null) throw const ServerException();
    final AppliedParcelSubscription? applied = _appliedFromJson(
      data['applied_subscription'],
    );
    // Without a plan nothing is discounted, whatever the field says.
    final double discount = applied == null
        ? 0
        : jsonDouble(data['subscription_discount']) ?? 0;

    return C2cParcelQuoteModel(
      quoteToken: jsonString(data['quote_token']),
      baseTotalFee: jsonDouble(data['base_total_fee']) ?? total + discount,
      subscriptionDiscount: discount,
      totalFee: total,
      currency: jsonString(data['currency']) ?? 'SAR',
      distanceKm: jsonDouble(data['distance_km']),
      estimatedDeliveryMinutes: jsonInt(data['estimated_delivery_minutes']),
      expiresAt: DateTime.tryParse(
        jsonString(data['quote_expires_at']) ??
            jsonString(data['expires_at']) ??
            '',
      ),
      appliedSubscription: applied,
    );
  }

  /// Null for a missing, null or non-object `applied_subscription`.
  static AppliedParcelSubscription? _appliedFromJson(dynamic json) {
    if (json is! Map) return null;
    final dynamic plan = json['plan'];
    return AppliedParcelSubscription(
      remainingDeliveries:
          jsonInt(json['remaining_deliveries']) ??
          jsonInt(json['deliveries_remaining']),
      subscriptionId: jsonInt(json['subscription_id']) ?? jsonInt(json['id']),
      planName:
          jsonString(json['plan_name']) ??
          (plan is Map ? jsonString(plan['name']) : null),
    );
  }
}
