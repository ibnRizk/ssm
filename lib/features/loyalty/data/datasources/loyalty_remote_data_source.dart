import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../models/loyalty_history_model.dart';
import '../models/loyalty_progress_model.dart';

abstract class LoyaltyRemoteDataSource {
  Future<LoyaltyProgressModel> getProgress();

  Future<LoyaltyHistoryModel> getHistory();
}

class LoyaltyRemoteDataSourceImpl implements LoyaltyRemoteDataSource {
  final DioConsumer consumer;

  const LoyaltyRemoteDataSourceImpl({required this.consumer});

  @override
  Future<LoyaltyProgressModel> getProgress() async =>
      LoyaltyProgressModel.fromJson(await consumer.get(ApiEndpoints.loyalty));

  @override
  Future<LoyaltyHistoryModel> getHistory() async =>
      LoyaltyHistoryModel.fromJson(
        await consumer.get(ApiEndpoints.loyaltyHistory),
      );
}
