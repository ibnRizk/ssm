import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/local_storage/app_secure_storage.dart';
import '../../domain/entities/login_credentials.dart';
import '../../domain/entities/registration_details.dart';
import '../../domain/repos/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/requests/login_request.dart';
import '../models/requests/register_request.dart';
import '../models/responses/auth_token_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final AppSecureStorage secureStorage;

  const AuthRepositoryImpl({required this.remote, required this.secureStorage});

  @override
  Future<Either<Failure, Unit>> login(LoginCredentials credentials) =>
      _authenticate(
        () => remote.login(LoginRequest.fromCredentials(credentials)),
      );

  @override
  Future<Either<Failure, Unit>> register(RegistrationDetails details) =>
      _authenticate(
        () => remote.register(RegisterRequest.fromDetails(details)),
      );

  Future<Either<Failure, Unit>> _authenticate(
    Future<AuthTokenResponse> Function() request,
  ) async {
    final AuthTokenResponse response;
    try {
      response = await request();
    } on AppException catch (error) {
      return Left(error.toFailure());
    } catch (_) {
      return const Left(ServerFailure());
    }

    try {
      await secureStorage.saveAccessToken(response.token);
    } catch (_) {
      // Keystore/Keychain failure. Without a stored token the next request
      // would be anonymous, so report the sign-in as failed.
      return const Left(CacheFailure());
    }
    return const Right(unit);
  }
}
