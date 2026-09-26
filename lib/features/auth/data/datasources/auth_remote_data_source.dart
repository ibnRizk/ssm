import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../models/requests/login_request.dart';
import '../models/requests/register_request.dart';
import '../models/responses/auth_token_response.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokenResponse> login(LoginRequest request);

  Future<AuthTokenResponse> register(RegisterRequest request);
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
}
