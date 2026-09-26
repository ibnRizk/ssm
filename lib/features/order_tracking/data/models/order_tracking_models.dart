import '../../../../core/api/json_readers.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/location/geo_point.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/order_tracking.dart';

/// Parsers for the order endpoints. Each throws [ServerException] when the
/// body can't be what the endpoint promises, and reads optional fields
/// leniently — the legacy shapes vary between backend versions.
abstract final class OrderTrackingModels {
  /// `order/track`: `{ id, order_status, order_amount, delivery_charge,
  /// store: { name, phone } }`.
  static OrderSummary summaryFromJson(dynamic json) {
    final int? id = json is Map ? jsonInt(json['id']) : null;
    if (json is! Map || id == null) throw const ServerException();
    final dynamic store = json['store'];
    return OrderSummary(
      id: id,
      legacyStatus: jsonString(json['order_status']),
      orderAmount: jsonDouble(json['order_amount']),
      deliveryCharge: jsonDouble(json['delivery_charge']),
      storeName: store is Map ? jsonString(store['name']) : null,
      storePhone: store is Map ? jsonString(store['phone']) : null,
    );
  }

  /// `order/details`: a list of `{ quantity, price, item_details }`, where
  /// `item_details` may arrive JSON-encoded as a string. Unusable lines
  /// are skipped.
  static List<OrderLine> linesFromJson(dynamic json) {
    if (json is! List) throw const ServerException();
    return json
        .map(_lineFromJson)
        .whereType<OrderLine>()
        .toList(growable: false);
  }

  static OrderLine? _lineFromJson(dynamic json) {
    if (json is! Map) return null;
    final dynamic details = jsonDecodedIfString(json['item_details']);
    final String? name = details is Map ? jsonString(details['name']) : null;
    final int? quantity = jsonInt(json['quantity']);
    final double? price = jsonDouble(json['price']);
    if (name == null || quantity == null || quantity < 1 || price == null) {
      return null;
    }
    return OrderLine(name: name, quantity: quantity, unitPrice: price);
  }

  /// `orders/{id}/tracking`: `{ order_id, ssm_status, tracking_allowed,
  /// driver: { name }, location: { latitude, longitude, is_fresh } }`.
  static OrderTracking trackingFromJson(dynamic json) {
    final int? orderId = json is Map ? jsonInt(json['order_id']) : null;
    if (json is! Map || orderId == null) throw const ServerException();
    final dynamic driver = json['driver'];
    return OrderTracking(
      orderId: orderId,
      status: statusFromWire(jsonString(json['ssm_status'])),
      trackingAllowed: jsonBool(json['tracking_allowed']) ?? false,
      driverName: driver is Map ? jsonString(driver['name']) : null,
      location: _locationFromJson(json['location']),
    );
  }

  static DriverLocation? _locationFromJson(dynamic json) {
    if (json is! Map) return null;
    final double? latitude = jsonDouble(json['latitude']);
    final double? longitude = jsonDouble(json['longitude']);
    if (latitude == null || longitude == null) return null;
    return DriverLocation(
      point: GeoPoint(latitude: latitude, longitude: longitude),
      isFresh: jsonBool(json['is_fresh']) ?? false,
    );
  }

  /// Null for a missing or unknown status — read as pending.
  static OrderStatus? statusFromWire(String? value) => switch (value) {
    'pending_merchant' => OrderStatus.pendingMerchant,
    'accepted' => OrderStatus.accepted,
    'preparing' => OrderStatus.preparing,
    'ready_for_pickup' => OrderStatus.readyForPickup,
    'dispatching' => OrderStatus.dispatching,
    'driver_assigned' => OrderStatus.driverAssigned,
    'driver_accepted' => OrderStatus.driverAccepted,
    'picked_up' => OrderStatus.pickedUp,
    'out_for_delivery' => OrderStatus.outForDelivery,
    'delivered' => OrderStatus.delivered,
    'rejected' => OrderStatus.rejected,
    'cancelled' => OrderStatus.cancelled,
    'assignment_failed' => OrderStatus.assignmentFailed,
    _ => null,
  };

  /// `{ "delivery_otp": { "challenge_id", "otp", "expires_at" } }`. A
  /// numeric `otp` keeps its leading zeros.
  static DeliveryOtp deliveryOtpFromJson(dynamic json) {
    final dynamic otp = json is Map ? json['delivery_otp'] : null;
    final String? code = otp is Map
        ? switch (otp['otp']) {
            final int v => v.toString().padLeft(6, '0'),
            final dynamic v => jsonString(v),
          }
        : null;
    if (code == null) throw const ServerException();
    final String? expiresAt = jsonString((otp as Map)['expires_at']);
    return DeliveryOtp(
      code: code,
      expiresAt: expiresAt == null ? null : DateTime.tryParse(expiresAt),
    );
  }
}
