import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/zone/zone_repository.dart';
import '../../../../core/zone/zone_scoped_call.dart';
import '../../domain/entities/order_tracking.dart';
import '../../domain/repos/order_tracking_repository.dart';
import '../datasources/order_tracking_remote_data_source.dart';

/// Order calls carry the zone headers, like the cart and checkout.
class OrderTrackingRepositoryImpl implements OrderTrackingRepository {
  final OrderTrackingRemoteDataSource remote;
  final ZoneRepository zoneRepository;

  OrderTrackingRepositoryImpl({
    required this.remote,
    required this.zoneRepository,
  });

  @override
  Future<Either<Failure, OrderSummary>> getSummary(int orderId) =>
      zoneRepository.inZone(() => remote.getSummary(orderId));

  @override
  Future<Either<Failure, List<OrderLine>>> getLines(int orderId) =>
      zoneRepository.inZone(() => remote.getLines(orderId));

  @override
  Future<Either<Failure, OrderTracking>> getTracking(int orderId) =>
      zoneRepository.inZone(() => remote.getTracking(orderId));

  @override
  Future<Either<Failure, DeliveryOtp>> requestDeliveryOtp(int orderId) =>
      zoneRepository.inZone(() => remote.requestDeliveryOtp(orderId));

  @override
  Future<Either<Failure, Unit>> cancelOrder(
    int orderId, {
    required String reason,
  }) => zoneRepository.inZone(() async {
    await remote.cancelOrder(orderId, reason: reason);
    return unit;
  });
}
