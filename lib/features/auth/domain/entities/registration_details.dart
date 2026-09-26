import 'package:equatable/equatable.dart';

/// A new customer account. Phone and email must be unique server-side.
class RegistrationDetails extends Equatable {
  /// First and last name in one field ("First Last").
  final String name;

  /// E.164, e.g. `+966512345678` — see `SaudiPhone.toE164`.
  final String phone;
  final String email;
  final String password;

  const RegistrationDetails({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, phone, email, password];
}
