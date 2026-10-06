import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/zone/zone_repository.dart';
import '../../../../core/zone/zone_scoped_call.dart';
import '../../domain/entities/store_promotion.dart';
import '../../domain/repos/promotions_repository.dart';
import '../datasources/promotions_remote_data_source.dart';

/// The endpoint refuses a request without the `zoneId` header — see
/// [ZoneScopedCall.inZone].
class PromotionsRepositoryImpl implements PromotionsRepository {
  final PromotionsRemoteDataSource remote;
  final ZoneRepository zoneRepository;

  const PromotionsRepositoryImpl({
    required this.remote,
    required this.zoneRepository,
  });

  @override
  Future<Either<Failure, List<StorePromotion>>> getFeaturedPromotions({
    int page = 1,
    int limit = featuredPromotionsLimit,
  }) => zoneRepository.inZone(
    () => remote.getFeaturedPromotions(page: page, limit: limit),
  );
}
