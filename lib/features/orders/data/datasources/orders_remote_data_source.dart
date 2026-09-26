import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../../catalog/domain/entities/catalog_page.dart';
import '../../domain/entities/order_list_entry.dart';
import '../models/orders_models.dart';

abstract class OrdersRemoteDataSource {
  Future<CatalogPage<OrderListEntry>> getRunningOrders({
    required int page,
    required int limit,
  });

  Future<CatalogPage<OrderListEntry>> getPastOrders({
    required int page,
    required int limit,
  });

  Future<List<OrderedItem>> getOrderedItems(int orderId);
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final DioConsumer consumer;

  const OrdersRemoteDataSourceImpl({required this.consumer});

  @override
  Future<CatalogPage<OrderListEntry>> getRunningOrders({
    required int page,
    required int limit,
  }) async => OrdersModels.pageFromJson(
    await consumer.get(
      ApiEndpoints.runningOrders,
      queryParameters: <String, dynamic>{'offset': page, 'limit': limit},
    ),
  );

  @override
  Future<CatalogPage<OrderListEntry>> getPastOrders({
    required int page,
    required int limit,
  }) async => OrdersModels.pageFromJson(
    await consumer.get(
      ApiEndpoints.orderHistory,
      queryParameters: <String, dynamic>{'offset': page, 'limit': limit},
    ),
  );

  @override
  Future<List<OrderedItem>> getOrderedItems(int orderId) async =>
      OrdersModels.orderedItemsFromJson(
        await consumer.get(
          ApiEndpoints.orderDetails,
          queryParameters: <String, dynamic>{'order_id': orderId},
        ),
      );
}
