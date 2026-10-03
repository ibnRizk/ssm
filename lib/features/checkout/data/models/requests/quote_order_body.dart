import '../../../domain/entities/order_quote.dart';
import 'place_order_body.dart';

/// The `POST /customer/order/quote` body — the same order type as placing.
class QuoteOrderBody {
  final QuoteRequest request;

  const QuoteOrderBody(this.request);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'store_id': request.storeId,
    'order_type': PlaceOrderBody.orderType,
    'distance': roundedDistance(request.distanceKm),
  };

  /// Metres are plenty; a long float tail only bloats the request.
  static double roundedDistance(double km) =>
      double.parse(km.toStringAsFixed(3));
}
