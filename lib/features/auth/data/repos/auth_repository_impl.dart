import 'package:dartz/dartz.dart';

import '../../../../core/api/safe_api_call.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/local_storage/app_secure_storage.dart';
import '../../../../core/services/local_storage/app_shared_preferences.dart';
import '../../domain/entities/login_credentials.dart';
import '../../domain/entities/registration_details.dart';
import '../../domain/repos/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/requests/login_request.dart';
import '../models/requests/password_reset_request.dart';
import '../models/requests/register_request.dart';
import '../models/responses/auth_token_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final AppSecureStorage secureStorage;
  final AppSharedPreferences sharedPreferences;

  const AuthRepositoryImpl({
    required this.remote,
    required this.secureStorage,
    required this.sharedPreferences,
  });

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      // Token first: once it's gone the session is over, even if clearing
      // the profile cache below fails.
      await secureStorage.removeAccessToken();
      await sharedPreferences.removeUser();
      await sharedPreferences.removeUserId();
      // The next customer on this device must resolve their own zone.
      await sharedPreferences.removeZoneIds();
    } catch (_) {
      return const Left(CacheFailure());
    }
    return const Right(unit);
  }

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

  @override
  Future<Either<Failure, Unit>> requestPasswordReset(String phone) =>
      safeApiCall(() async {
        await remote.requestPasswordReset(PasswordResetRequest(phone: phone));
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> verifyPasswordResetCode({
    required String phone,
    required String code,
  }) => safeApiCall(() async {
    await remote.verifyPasswordResetCode(
      PasswordResetRequest(phone: phone, code: code),
    );
    return unit;
  });

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String phone,
    required String code,
    required String password,
  }) => safeApiCall(() async {
    await remote.resetPassword(
      PasswordResetRequest(phone: phone, code: code, password: password),
    );
    return unit;
  });

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
