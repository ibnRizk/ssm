import '../../../domain/entities/order_request.dart';
import 'quote_order_body.dart';

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
    // The distance the quote was made for, so the fee matches what the
    // customer saw.
    'distance': QuoteOrderBody.roundedDistance(request.distanceKm),
    'address': request.deliveryAddress,
    'latitude': request.location.latitude.toString(),
    'longitude': request.location.longitude.toString(),
    'contact_person_name': request.contactPersonName,
    'contact_person_number': request.contactPersonNumber,
  };
}
