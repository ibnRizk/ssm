import 'package:equatable/equatable.dart';

import '../../../../core/location/geo_point.dart';
import 'order_status.dart';

/// `GET /customer/order/track` — the legacy summary.
class OrderSummary extends Equatable {
  final int id;

  /// The legacy `order_status` — see [OrderStatus.resolve].
  final String? legacyStatus;
  final double? orderAmount;
  final double? deliveryCharge;
  final String? storeName;
  final String? storePhone;

  const OrderSummary({
    required this.id,
    this.legacyStatus,
    this.orderAmount,
    this.deliveryCharge,
    this.storeName,
    this.storePhone,
  });

  @override
  List<Object?> get props => [
    id,
    legacyStatus,
    orderAmount,
    deliveryCharge,
    storeName,
    storePhone,
  ];
}

/// One line of `GET /customer/order/details`.
class OrderLine extends Equatable {
  final String name;
  final int quantity;
  final double unitPrice;

  const OrderLine({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  double get lineTotal => unitPrice * quantity;

  @override
  List<Object?> get props => [name, quantity, unitPrice];
}

/// The driver's last reported position.
class DriverLocation extends Equatable {
  final GeoPoint point;

  /// False when the last position is older than the backend's freshness
  /// window — show "location unavailable" then.
  final bool isFresh;

  const DriverLocation({required this.point, required this.isFresh});

  @override
  List<Object?> get props => [point, isFresh];
}

/// `GET /customer/orders/{id}/tracking` — the SSM shape.
class OrderTracking extends Equatable {
  final int orderId;

  /// `ssm_status`; null until the merchant first acts on the order.
  final OrderStatus? status;
  final bool trackingAllowed;

  /// Only while a driver is on the order. No phone is shared.
  final String? driverName;
  final DriverLocation? location;

  const OrderTracking({
    required this.orderId,
    this.status,
    this.trackingAllowed = false,
    this.driverName,
    this.location,
  });

  @override
  List<Object?> get props => [
    orderId,
    status,
    trackingAllowed,
    driverName,
    location,
  ];
}

/// The code the customer tells the courier to complete the delivery.
/// Requesting another one invalidates this one.
class DeliveryOtp extends Equatable {
  final String code;
  final DateTime? expiresAt;

  const DeliveryOtp({required this.code, this.expiresAt});

  @override
  List<Object?> get props => [code, expiresAt];
}
