import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/saudi_phone.dart';
import '../../domain/repos/auth_repository.dart';
import 'forgot_password_state.dart';

/// Screen-scoped (one instance per Forgot Password route). Walks phone →
/// code → new password; each step only advances when its request succeeds.
class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final AuthRepository repository;

  ForgotPasswordCubit({required this.repository})
    : super(const ForgotPasswordEnterPhone());

  /// [phone] as typed in the form.
  Future<void> requestCode(String phone) async {
    if (state case final ForgotPasswordEnterPhone current
        when !current.isSubmitting) {
      final String e164 = SaudiPhone.toE164(phone);
      emit(ForgotPasswordEnterPhone(phone: phone, isSubmitting: true));
      final Either<Failure, Unit> result = await repository
          .requestPasswordReset(e164);
      if (isClosed) return;
      emit(
        result.fold(
          (Failure f) => ForgotPasswordEnterPhone(phone: phone, failure: f),
          (_) => ForgotPasswordEnterCode(phone: e164),
        ),
      );
    }
  }

  Future<void> resendCode() async {
    if (state case final ForgotPasswordEnterCode current
        when !current.isSubmitting) {
      emit(_code(current, isSubmitting: true));
      final Either<Failure, Unit> result = await repository
          .requestPasswordReset(current.phone);
      if (isClosed) return;
      emit(
        result.fold(
          (Failure f) => _code(current, failure: f),
          (_) => _code(current, resends: current.resends + 1),
        ),
      );
    }
  }

  Future<void> verifyCode(String code) async {
    if (state case final ForgotPasswordEnterCode current
        when !current.isSubmitting) {
      final String trimmed = code.trim();
      emit(_code(current, isSubmitting: true));
      final Either<Failure, Unit> result = await repository
          .verifyPasswordResetCode(phone: current.phone, code: trimmed);
      if (isClosed) return;
      emit(
        result.fold(
          (Failure f) => _code(current, failure: f),
          (_) => ForgotPasswordEnterNewPassword(
            phone: current.phone,
            code: trimmed,
          ),
        ),
      );
    }
  }

  Future<void> resetPassword(String password) async {
    if (state case final ForgotPasswordEnterNewPassword current
        when !current.isSubmitting) {
      emit(_newPassword(current, isSubmitting: true));
      final Either<Failure, Unit> result = await repository.resetPassword(
        phone: current.phone,
        code: current.code,
        password: password,
      );
      if (isClosed) return;
      emit(
        result.fold(
          (Failure f) => _newPassword(current, failure: f),
          (_) => const ForgotPasswordDone(),
        ),
      );
    }
  }

  /// One step back. False on the first step — the screen then leaves.
  /// Ignored while a request is in flight.
  bool back() {
    final ForgotPasswordState current = state;
    if (current.isSubmitting) return true;
    switch (current) {
      case ForgotPasswordEnterCode(:final String phone):
        emit(ForgotPasswordEnterPhone(phone: SaudiPhone.toLocal(phone)));
        return true;
      case ForgotPasswordEnterNewPassword(:final String phone):
        // Re-enter or resend the code.
        emit(ForgotPasswordEnterCode(phone: phone));
        return true;
      case ForgotPasswordEnterPhone() || ForgotPasswordDone():
        return false;
    }
  }

  static ForgotPasswordEnterCode _code(
    ForgotPasswordEnterCode from, {
    bool isSubmitting = false,
    Failure? failure,
    int? resends,
  }) => ForgotPasswordEnterCode(
    phone: from.phone,
    resends: resends ?? from.resends,
    isSubmitting: isSubmitting,
    failure: failure,
  );

  static ForgotPasswordEnterNewPassword _newPassword(
    ForgotPasswordEnterNewPassword from, {
    bool isSubmitting = false,
    Failure? failure,
  }) => ForgotPasswordEnterNewPassword(
    phone: from.phone,
    code: from.code,
    isSubmitting: isSubmitting,
    failure: failure,
  );
}
