import 'package:dartz/dartz.dart';

import '../../../../core/api/safe_api_call.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/customer_profile.dart';
import '../../domain/repos/account_repository.dart';
import '../datasources/account_remote_data_source.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remote;

  const AccountRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, CustomerProfile>> getProfile() =>
      safeApiCall(remote.getProfile);
}
