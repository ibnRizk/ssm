import 'package:dartz/dartz.dart';

import '../api/safe_api_call.dart';
import '../error/failures.dart';
import 'app_config.dart';
import 'app_config_remote_data_source.dart';
import 'app_config_repository.dart';

class AppConfigRepositoryImpl implements AppConfigRepository {
  final AppConfigRemoteDataSource remote;

  const AppConfigRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, AppConfig>> getConfig() =>
      safeApiCall(remote.getConfig);
}
