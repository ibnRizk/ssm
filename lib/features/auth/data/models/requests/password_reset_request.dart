/// Bodies of the three password-recovery calls. Each step repeats what the
/// one before sent; the backend also accepts `email` as the method, the app
/// only offers phone.
class PasswordResetRequest {
  final String phone;

  /// The texted one-time code — the API calls it `reset_token`.
  final String? code;
  final String? password;

  const PasswordResetRequest({required this.phone, this.code, this.password});

  /// `POST /auth/forgot-password`.
  Map<String, dynamic> toRequestCodeJson() => <String, dynamic>{
    'verification_method': 'phone',
    'phone': phone,
  };

  /// `POST /auth/verify-token`.
  Map<String, dynamic> toVerifyJson() => <String, dynamic>{
    ...toRequestCodeJson(),
    'reset_token': code,
  };

  /// `PUT /auth/reset-password`. The form already checked the two match.
  Map<String, dynamic> toResetJson() => <String, dynamic>{
    ...toVerifyJson(),
    'password': password,
    'confirm_password': password,
  };
}
