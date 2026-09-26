import 'package:equatable/equatable.dart';

/// A manual phone + password sign-in.
class LoginCredentials extends Equatable {
  /// E.164, e.g. `+966512345678` — see `SaudiPhone.toE164`.
  final String phone;
  final String password;

  const LoginCredentials({required this.phone, required this.password});

  @override
  List<Object?> get props => [phone, password];
}
