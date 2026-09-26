import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/zone/zone_repository.dart';
import '../../../../core/zone/zone_scoped_call.dart';
import '../../../catalog/domain/entities/catalog_page.dart';
import '../../domain/entities/order_list_entry.dart';
import '../../domain/repos/orders_repository.dart';
import '../datasources/orders_remote_data_source.dart';

/// Order calls carry the zone headers, like the cart and checkout.
class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remote;
  final ZoneRepository zoneRepository;

  const OrdersRepositoryImpl({
    required this.remote,
    required this.zoneRepository,
  });

  @override
  Future<Either<Failure, CatalogPage<OrderListEntry>>> getRunningOrders({
    required int page,
    int pageSize = ordersPageSize,
  }) => zoneRepository.inZone(
    () => remote.getRunningOrders(page: page, limit: pageSize),
  );

  @override
  Future<Either<Failure, CatalogPage<OrderListEntry>>> getPastOrders({
    required int page,
    int pageSize = ordersPageSize,
  }) => zoneRepository.inZone(
    () => remote.getPastOrders(page: page, limit: pageSize),
  );

  @override
  Future<Either<Failure, List<OrderedItem>>> getOrderedItems(int orderId) =>
      zoneRepository.inZone(() => remote.getOrderedItems(orderId));
}
