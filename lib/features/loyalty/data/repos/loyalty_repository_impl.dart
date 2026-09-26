import 'package:dartz/dartz.dart';

import '../../../../core/api/safe_api_call.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/loyalty_progress.dart';
import '../../domain/repos/loyalty_repository.dart';
import '../datasources/loyalty_remote_data_source.dart';

class LoyaltyRepositoryImpl implements LoyaltyRepository {
  final LoyaltyRemoteDataSource remote;

  const LoyaltyRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, LoyaltyProgress>> getProgress() =>
      safeApiCall(remote.getProgress);
}
