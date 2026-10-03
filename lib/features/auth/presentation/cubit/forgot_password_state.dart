import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';

/// One subtype per step of the flow. Every step carries whether a request is
/// in flight and the last request's [failure] (reset to null on the next
/// submit), so the screen can spin the button and surface errors without
/// leaving the step.
sealed class ForgotPasswordState extends Equatable {
  final bool isSubmitting;
  final Failure? failure;

  const ForgotPasswordState({this.isSubmitting = false, this.failure});

  @override
  List<Object?> get props => [isSubmitting, failure];
}

final class ForgotPasswordEnterPhone extends ForgotPasswordState {
  /// What was entered before going back from the code step, to prefill —
  /// as typed (local form), not E.164.
  final String phone;

  const ForgotPasswordEnterPhone({
    this.phone = '',
    super.isSubmitting,
    super.failure,
  });

  @override
  List<Object?> get props => [...super.props, phone];
}

final class ForgotPasswordEnterCode extends ForgotPasswordState {
  /// E.164, as the backend knows the account.
  final String phone;

  /// Bumped on every successful resend so the screen can confirm it.
  final int resends;

  const ForgotPasswordEnterCode({
    required this.phone,
    this.resends = 0,
    super.isSubmitting,
    super.failure,
  });

  @override
  List<Object?> get props => [...super.props, phone, resends];
}

final class ForgotPasswordEnterNewPassword extends ForgotPasswordState {
  final String phone;
  final String code;

  const ForgotPasswordEnterNewPassword({
    required this.phone,
    required this.code,
    super.isSubmitting,
    super.failure,
  });

  @override
  List<Object?> get props => [...super.props, phone, code];
}

/// The password is changed — back to Login to sign in with it.
final class ForgotPasswordDone extends ForgotPasswordState {
  const ForgotPasswordDone();
}
