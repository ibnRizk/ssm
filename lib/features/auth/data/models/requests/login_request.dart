import '../../../domain/entities/login_credentials.dart';

/// Body of `POST /auth/login` — manual sign-in by phone.
class LoginRequest {
  final String phone;
  final String password;

  const LoginRequest({required this.phone, required this.password});

  factory LoginRequest.fromCredentials(LoginCredentials credentials) =>
      LoginRequest(phone: credentials.phone, password: credentials.password);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'login_type': 'manual',
    'email_or_phone': phone,
    'field_type': 'phone',
    'password': password,
  };
}
