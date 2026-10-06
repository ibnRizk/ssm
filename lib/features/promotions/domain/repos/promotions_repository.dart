import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/store_promotion.dart';

/// Scoped to the customer's delivery zone, like the catalog; a
/// [ZoneUnavailableFailure] means there's no zone to promote stores in.
abstract class PromotionsRepository {
  /// The zone's featured store promotions, in the backend's order. [page] is
  /// 1-based.
  Future<Either<Failure, List<StorePromotion>>> getFeaturedPromotions({
    int page = 1,
    int limit = featuredPromotionsLimit,
  });
}

const int featuredPromotionsLimit = 10;
