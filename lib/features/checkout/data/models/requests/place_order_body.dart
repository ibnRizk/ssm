import '../../../domain/entities/order_request.dart';

/// The `POST /customer/order/place` body. Only cash on delivery is enabled.
class PlaceOrderBody {
  final OrderRequest request;

  const PlaceOrderBody(this.request);

  static const String orderType = 'delivery';
  static const String paymentMethod = 'cash_on_delivery';

  Map<String, dynamic> toJson() => <String, dynamic>{
    'order_type': orderType,
    'payment_method': paymentMethod,
    'store_id': request.storeId,
    'order_amount': request.orderAmount,
    // Required by validation but not authoritative: the server measures
    // the distance itself when it recomputes the delivery fee.
    'distance': 0,
    'address': request.deliveryAddress,
    'latitude': request.location.latitude.toString(),
    'longitude': request.location.longitude.toString(),
    'contact_person_name': request.contactPersonName,
    'contact_person_number': request.contactPersonNumber,
  };
}
