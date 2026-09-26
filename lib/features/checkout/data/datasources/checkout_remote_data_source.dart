import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../models/placed_order_model.dart';
import '../models/requests/place_order_body.dart';

abstract class CheckoutRemoteDataSource {
  Future<PlacedOrderModel> placeOrder(PlaceOrderBody body);
}

class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  final DioConsumer consumer;

  CheckoutRemoteDataSourceImpl({required this.consumer});

  @override
  Future<PlacedOrderModel> placeOrder(PlaceOrderBody body) async =>
      PlacedOrderModel.fromJson(
        await consumer.post(ApiEndpoints.orderPlace, body: body.toJson()),
      );
}
