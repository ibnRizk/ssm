import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../models/promotion_model.dart';

/// The `zoneId` / `moduleId` headers this endpoint needs are added by
/// `AppInterceptors`.
abstract class PromotionsRemoteDataSource {
  Future<List<PromotionModel>> getFeaturedPromotions({
    required int page,
    required int limit,
  });
}

class PromotionsRemoteDataSourceImpl implements PromotionsRemoteDataSource {
  final DioConsumer consumer;

  const PromotionsRemoteDataSourceImpl({required this.consumer});

  @override
  Future<List<PromotionModel>> getFeaturedPromotions({
    required int page,
    required int limit,
  }) async => PromotionModel.listFromJson(
    await consumer.get(
      ApiEndpoints.featuredPromotions,
      queryParameters: <String, dynamic>{'limit': limit, 'page': page},
    ),
  );
}
