import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../models/loyalty_progress_model.dart';

abstract class LoyaltyRemoteDataSource {
  Future<LoyaltyProgressModel> getProgress();
}

class LoyaltyRemoteDataSourceImpl implements LoyaltyRemoteDataSource {
  final DioConsumer consumer;

  const LoyaltyRemoteDataSourceImpl({required this.consumer});

  @override
  Future<LoyaltyProgressModel> getProgress() async =>
      LoyaltyProgressModel.fromJson(await consumer.get(ApiEndpoints.loyalty));
}
