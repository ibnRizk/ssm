import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/zone/zone_repository.dart';
import '../../../../core/zone/zone_scoped_call.dart';
import '../../domain/entities/order_request.dart';
import '../../domain/repos/checkout_repository.dart';
import '../datasources/checkout_remote_data_source.dart';
import '../models/requests/place_order_body.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource remote;
  final ZoneRepository zoneRepository;

  CheckoutRepositoryImpl({required this.remote, required this.zoneRepository});

  /// The order goes out in the delivery address's zone: switching to it
  /// first means the `zoneId` header matches the coordinates sent, and the
  /// catalog follows the address the customer now uses.
  @override
  Future<Either<Failure, PlacedOrder>> placeOrder(OrderRequest request) async {
    final int? zoneId = request.zoneId;
    if (zoneId != null) {
      final Either<Failure, Unit> switched = await zoneRepository
          .selectZoneIds(<int>[zoneId]);
      if (switched case Left<Failure, Unit>(:final Failure value)) {
        return Left<Failure, PlacedOrder>(value);
      }
    }
    return zoneRepository.inZone(
      () => remote.placeOrder(PlaceOrderBody(request)),
    );
  }
}
