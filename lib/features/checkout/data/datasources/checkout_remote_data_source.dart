import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../models/order_quote_model.dart';
import '../models/placed_order_model.dart';
import '../models/requests/place_order_body.dart';
import '../models/requests/quote_order_body.dart';

abstract class CheckoutRemoteDataSource {
  Future<OrderQuoteModel> getQuote(QuoteOrderBody body);

  Future<PlacedOrderModel> placeOrder(
    PlaceOrderBody body, {
    required String idempotencyKey,
  });
}

class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  final DioConsumer consumer;

  CheckoutRemoteDataSourceImpl({required this.consumer});

  static const String idempotencyHeader = 'Idempotency-Key';

  @override
  Future<OrderQuoteModel> getQuote(QuoteOrderBody body) async =>
      OrderQuoteModel.fromJson(
        await consumer.post(ApiEndpoints.orderQuote, body: body.toJson()),
      );

  @override
  Future<PlacedOrderModel> placeOrder(
    PlaceOrderBody body, {
    required String idempotencyKey,
  }) async => PlacedOrderModel.fromJson(
    await consumer.post(
      ApiEndpoints.orderPlace,
      body: body.toJson(),
      headers: <String, String>{idempotencyHeader: idempotencyKey},
    ),
  );
}
