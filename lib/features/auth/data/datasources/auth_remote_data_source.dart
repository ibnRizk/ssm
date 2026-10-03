import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_error_mapper.dart';
import '../../../../core/api/dio_consumer.dart';
import '../models/requests/login_request.dart';
import '../models/requests/password_reset_request.dart';
import '../models/requests/register_request.dart';
import '../models/responses/auth_token_response.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokenResponse> login(LoginRequest request);

  Future<AuthTokenResponse> register(RegisterRequest request);

  /// The three recovery steps answer only a confirmation message, so nothing
  /// is parsed — but an `errors` body is thrown as a [ForbiddenException],
  /// as the legacy auth controllers may refuse with a success status.
  Future<void> requestPasswordReset(PasswordResetRequest request);

  Future<void> verifyPasswordResetCode(PasswordResetRequest request);

  Future<void> resetPassword(PasswordResetRequest request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioConsumer consumer;

  const AuthRemoteDataSourceImpl({required this.consumer});

  @override
  Future<AuthTokenResponse> login(LoginRequest request) async {
    final dynamic data = await consumer.post(
      ApiEndpoints.login,
      body: request.toJson(),
    );
    return AuthTokenResponse.fromJson(data);
  }

  @override
  Future<AuthTokenResponse> register(RegisterRequest request) async {
    final dynamic data = await consumer.post(
      ApiEndpoints.signUp,
      body: request.toJson(),
    );
    return AuthTokenResponse.fromJson(data);
  }

  @override
  Future<void> requestPasswordReset(PasswordResetRequest request) async =>
      throwIfRefusal(
        await consumer.post(
          ApiEndpoints.forgotPassword,
          body: request.toRequestCodeJson(),
        ),
      );

  @override
  Future<void> verifyPasswordResetCode(PasswordResetRequest request) async =>
      throwIfRefusal(
        await consumer.post(
          ApiEndpoints.verifyResetToken,
          body: request.toVerifyJson(),
        ),
      );

  @override
  Future<void> resetPassword(PasswordResetRequest request) async =>
      throwIfRefusal(
        await consumer.put(
          ApiEndpoints.resetPassword,
          body: request.toResetJson(),
        ),
      );
}
