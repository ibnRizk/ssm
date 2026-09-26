import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../catalog/domain/entities/catalog_page.dart';
import '../entities/order_list_entry.dart';

const int ordersPageSize = 10;

/// The signed-in customer's orders. Running and past orders are disjoint:
/// an order leaves the running list once it's delivered or cancelled.
abstract class OrdersRepository {
  /// [page] is 1-based.
  Future<Either<Failure, CatalogPage<OrderListEntry>>> getRunningOrders({
    required int page,
    int pageSize = ordersPageSize,
  });

  /// Newest first. [page] is 1-based.
  Future<Either<Failure, CatalogPage<OrderListEntry>>> getPastOrders({
    required int page,
    int pageSize = ordersPageSize,
  });

  /// The order's lines, to order them again.
  Future<Either<Failure, List<OrderedItem>>> getOrderedItems(int orderId);
}
