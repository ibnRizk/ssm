import '../../../domain/entities/login_credentials.dart';

/// Body of `POST /auth/login` — manual sign-in by phone.
class LoginRequest {
  final String phone;
  final String password;

  /// The guest this device browsed as, if any — the backend merges that
  /// guest's cart into the account.
  final int? guestId;

  const LoginRequest({
    required this.phone,
    required this.password,
    this.guestId,
  });

  factory LoginRequest.fromCredentials(
    LoginCredentials credentials, {
    int? guestId,
  }) => LoginRequest(
    phone: credentials.phone,
    password: credentials.password,
    guestId: guestId,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'login_type': 'manual',
    'email_or_phone': phone,
    'field_type': 'phone',
    'password': password,
    'guest_id': ?guestId,
  };
}
