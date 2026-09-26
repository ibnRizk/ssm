import 'package:equatable/equatable.dart';

import '../../../../core/location/geo_point.dart';

/// Why an order can't be placed yet — checked before anything is sent.
enum CheckoutIssue {
  emptyCart,

  /// The cart lines don't say which store they're from.
  unknownStore,
  noAddress,

  /// The saved address has no map pin; the backend needs coordinates.
  addressWithoutLocation,
}

/// A cash-on-delivery order for the customer's cart. The server builds the
/// order from the cart and recomputes prices, tax and the delivery fee, so
/// [orderAmount] only satisfies validation.
class OrderRequest extends Equatable {
  final int storeId;
  final double orderAmount;
  final String deliveryAddress;
  final GeoPoint location;
  final String contactPersonName;
  final String contactPersonNumber;

  /// The delivery address's zone; the order is scoped to it when known.
  final int? zoneId;

  const OrderRequest({
    required this.storeId,
    required this.orderAmount,
    required this.deliveryAddress,
    required this.location,
    required this.contactPersonName,
    required this.contactPersonNumber,
    this.zoneId,
  });

  @override
  List<Object?> get props => [
    storeId,
    orderAmount,
    deliveryAddress,
    location,
    contactPersonName,
    contactPersonNumber,
    zoneId,
  ];
}

/// The server's answer to a placed order.
class PlacedOrder extends Equatable {
  final int id;

  /// The server-computed total, delivery included. Null when not sent.
  final double? totalAmount;

  const PlacedOrder({required this.id, this.totalAmount});

  @override
  List<Object?> get props => [id, totalAmount];
}
