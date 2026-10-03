import 'package:dartz/dartz.dart';

import '../../../../core/api/safe_api_call.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/customer_profile.dart';
import '../../domain/repos/account_repository.dart';
import '../datasources/account_remote_data_source.dart';
import '../models/requests/update_profile_request.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remote;

  const AccountRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, CustomerProfile>> getProfile() =>
      safeApiCall(remote.getProfile);

  @override
  Future<Either<Failure, Unit>> updateProfile(ProfileUpdate update) =>
      safeApiCall(() async {
        await remote.updateProfile(UpdateProfileRequest.fromUpdate(update));
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> deleteAccount() => safeApiCall(() async {
    await remote.deleteAccount();
    return unit;
  });
}
