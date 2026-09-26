import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/zone/zone_repository.dart';
import '../../../../core/zone/zone_scoped_call.dart';
import '../../domain/entities/cart.dart';
import '../../domain/repos/cart_repository.dart';
import '../datasources/cart_remote_data_source.dart';

/// Cart calls need the zone headers, like the catalog's.
class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remote;
  final ZoneRepository zoneRepository;

  const CartRepositoryImpl({
    required this.remote,
    required this.zoneRepository,
  });

  @override
  Future<Either<Failure, Cart>> getCart() =>
      zoneRepository.inZone(remote.getCart);

  @override
  Future<Either<Failure, Cart>> addItem({
    required int itemId,
    required double unitPrice,
    int quantity = 1,
  }) => zoneRepository.inZone(
    () => remote.addItem(
      itemId: itemId,
      unitPrice: unitPrice,
      quantity: quantity,
    ),
  );

  @override
  Future<Either<Failure, Cart>> updateQuantity({
    required int cartLineId,
    required int quantity,
  }) {
    assert(quantity >= 1, 'use removeLine to drop a line');
    return zoneRepository.inZone(
      () => remote.updateQuantity(cartLineId: cartLineId, quantity: quantity),
    );
  }

  @override
  Future<Either<Failure, Cart>> removeLine(int cartLineId) =>
      zoneRepository.inZone(() => remote.removeLine(cartLineId));
}
