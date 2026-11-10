import '../../../domain/entities/registration_details.dart';

/// Body of `POST /auth/sign-up`.
class RegisterRequest {
  final String name;
  final String phone;
  final String email;
  final String password;

  /// See [LoginRequest.guestId] — the guest cart moves to the new account.
  final int? guestId;

  const RegisterRequest({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    this.guestId,
  });

  factory RegisterRequest.fromDetails(
    RegistrationDetails details, {
    int? guestId,
  }) => RegisterRequest(
    name: details.name,
    phone: details.phone,
    email: details.email,
    password: details.password,
    guestId: guestId,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'phone': phone,
    'email': email,
    'password': password,
    'guest_id': ?guestId,
  };
}
