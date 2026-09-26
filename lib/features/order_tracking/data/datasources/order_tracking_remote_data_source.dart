import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../domain/entities/order_tracking.dart';
import '../models/order_tracking_models.dart';

abstract class OrderTrackingRemoteDataSource {
  Future<OrderSummary> getSummary(int orderId);

  Future<List<OrderLine>> getLines(int orderId);

  Future<OrderTracking> getTracking(int orderId);

  Future<DeliveryOtp> requestDeliveryOtp(int orderId);
}

class OrderTrackingRemoteDataSourceImpl
    implements OrderTrackingRemoteDataSource {
  final DioConsumer consumer;

  OrderTrackingRemoteDataSourceImpl({required this.consumer});

  @override
  Future<OrderSummary> getSummary(int orderId) async =>
      OrderTrackingModels.summaryFromJson(
        await consumer.get(
          ApiEndpoints.orderTrack,
          queryParameters: <String, dynamic>{'order_id': orderId},
        ),
      );

  @override
  Future<List<OrderLine>> getLines(int orderId) async =>
      OrderTrackingModels.linesFromJson(
        await consumer.get(
          ApiEndpoints.orderDetails,
          queryParameters: <String, dynamic>{'order_id': orderId},
        ),
      );

  @override
  Future<OrderTracking> getTracking(int orderId) async =>
      OrderTrackingModels.trackingFromJson(
        await consumer.get(ApiEndpoints.orderTracking(orderId)),
      );

  @override
  Future<DeliveryOtp> requestDeliveryOtp(int orderId) async =>
      OrderTrackingModels.deliveryOtpFromJson(
        await consumer.post(ApiEndpoints.deliveryOtpRequest(orderId)),
      );
}
