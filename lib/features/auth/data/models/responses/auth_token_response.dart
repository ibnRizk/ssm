import '../../../../../core/error/exceptions.dart';

/// `{ "token": "..." }` — returned by both `/auth/login` and `/auth/sign-up`.
class AuthTokenResponse {
  final String token;

  const AuthTokenResponse({required this.token});

  /// Throws [ServerException] when the body has no usable token, so a
  /// malformed 200 can never be mistaken for a signed-in session.
  factory AuthTokenResponse.fromJson(dynamic json) {
    final dynamic token = json is Map ? json['token'] : null;
    if (token is! String || token.trim().isEmpty) {
      throw const ServerException();
    }
    return AuthTokenResponse(token: token);
  }
}
