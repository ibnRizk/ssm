import '../api/api_endpoints.dart';
import '../api/dio_consumer.dart';
import 'app_config_model.dart';

abstract class AppConfigRemoteDataSource {
  Future<AppConfigModel> getConfig();
}

class AppConfigRemoteDataSourceImpl implements AppConfigRemoteDataSource {
  final DioConsumer consumer;

  const AppConfigRemoteDataSourceImpl({required this.consumer});

  @override
  Future<AppConfigModel> getConfig() async =>
      AppConfigModel.fromJson(await consumer.get(ApiEndpoints.customerConfig));
}
