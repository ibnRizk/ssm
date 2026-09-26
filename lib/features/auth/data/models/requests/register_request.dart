import '../../../domain/entities/registration_details.dart';

/// Body of `POST /auth/sign-up`.
class RegisterRequest {
  final String name;
  final String phone;
  final String email;
  final String password;

  const RegisterRequest({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
  });

  factory RegisterRequest.fromDetails(RegistrationDetails details) =>
      RegisterRequest(
        name: details.name,
        phone: details.phone,
        email: details.email,
        password: details.password,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'phone': phone,
    'email': email,
    'password': password,
  };
}
