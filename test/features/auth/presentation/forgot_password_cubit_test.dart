import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/features/auth/domain/entities/login_credentials.dart';
import 'package:ssm/features/auth/domain/entities/registration_details.dart';
import 'package:ssm/features/auth/domain/repos/auth_repository.dart';
import 'package:ssm/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:ssm/features/auth/presentation/cubit/forgot_password_state.dart';

class _FakeRepository implements AuthRepository {
  Either<Failure, Unit> result = const Right<Failure, Unit>(unit);

  /// When set, calls wait on it — lets a test observe the in-flight state.
  Completer<void>? gate;

  final List<String> requested = <String>[];
  final List<(String, String)> verified = <(String, String)>[];
  final List<(String, String, String)> resets = <(String, String, String)>[];

  Future<Either<Failure, Unit>> _answer() async {
    await gate?.future;
    return result;
  }

  @override
  Future<Either<Failure, Unit>> requestPasswordReset(String phone) {
    requested.add(phone);
    return _answer();
  }

  @override
  Future<Either<Failure, Unit>> verifyPasswordResetCode({
    required String phone,
    required String code,
  }) {
    verified.add((phone, code));
    return _answer();
  }

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String phone,
    required String code,
    required String password,
  }) {
    resets.add((phone, code, password));
    return _answer();
  }

  @override
  Future<Either<Failure, Unit>> login(LoginCredentials credentials) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> register(RegistrationDetails details) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> logout() => throw UnimplementedError();
}

const String _e164 = '+966512345678';

void main() {
  late _FakeRepository repository;
  late ForgotPasswordCubit cubit;

  setUp(() {
    repository = _FakeRepository();
    cubit = ForgotPasswordCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  /// Walks to the code step.
  Future<void> toCodeStep() => cubit.requestCode('0512345678');

  /// Walks to the new-password step.
  Future<void> toNewPasswordStep() async {
    await toCodeStep();
    await cubit.verifyCode('1234');
  }

  test('starts on the phone step', () {
    expect(cubit.state, const ForgotPasswordEnterPhone());
  });

  group('requestCode', () {
    test('sends the phone in E.164 form', () async {
      await cubit.requestCode('05 1234 5678');

      expect(repository.requested.single, _e164);
    });

    test('moves to the code step on success', () async {
      await toCodeStep();

      expect(cubit.state, const ForgotPasswordEnterCode(phone: _e164));
    });

    test('stays on the phone step with the failure', () async {
      repository.result = const Left<Failure, Unit>(NotFoundFailure());

      await cubit.requestCode('0512345678');

      expect(
        cubit.state,
        const ForgotPasswordEnterPhone(
          phone: '0512345678',
          failure: NotFoundFailure(),
        ),
      );
    });

    test('ignores a second submit while the first is in flight', () async {
      repository.gate = Completer<void>();

      final Future<void> first = cubit.requestCode('0512345678');
      await cubit.requestCode('0512345678');
      repository.gate!.complete();
      await first;

      expect(repository.requested, hasLength(1));
    });
  });

  group('verifyCode', () {
    test('sends the trimmed code with the phone', () async {
      await toCodeStep();

      await cubit.verifyCode(' 1234 ');

      expect(repository.verified.single, (_e164, '1234'));
    });

    test('moves to the new-password step on success', () async {
      await toNewPasswordStep();

      expect(
        cubit.state,
        const ForgotPasswordEnterNewPassword(phone: _e164, code: '1234'),
      );
    });

    test('stays on the code step with the failure', () async {
      await toCodeStep();
      repository.result = const Left<Failure, Unit>(
        ServerFailure(message: 'Invalid OTP'),
      );

      await cubit.verifyCode('0000');

      expect(
        cubit.state,
        const ForgotPasswordEnterCode(
          phone: _e164,
          failure: ServerFailure(message: 'Invalid OTP'),
        ),
      );
    });

    test('is ignored outside the code step', () async {
      await cubit.verifyCode('1234');

      expect(repository.verified, isEmpty);
    });
  });

  group('resendCode', () {
    test('requests a new code for the same phone', () async {
      await toCodeStep();

      await cubit.resendCode();

      expect(repository.requested, <String>[_e164, _e164]);
    });

    test('counts successful resends', () async {
      await toCodeStep();

      await cubit.resendCode();

      expect(
        cubit.state,
        const ForgotPasswordEnterCode(phone: _e164, resends: 1),
      );
    });
  });

  group('resetPassword', () {
    test('sends the verified code with the new password', () async {
      await toNewPasswordStep();

      await cubit.resetPassword('newSecret1');

      expect(repository.resets.single, (_e164, '1234', 'newSecret1'));
    });

    test('finishes on success', () async {
      await toNewPasswordStep();

      await cubit.resetPassword('newSecret1');

      expect(cubit.state, const ForgotPasswordDone());
    });

    test('stays on the step with the failure', () async {
      await toNewPasswordStep();
      repository.result = const Left<Failure, Unit>(NetworkFailure());

      await cubit.resetPassword('newSecret1');

      expect(
        cubit.state,
        const ForgotPasswordEnterNewPassword(
          phone: _e164,
          code: '1234',
          failure: NetworkFailure(),
        ),
      );
    });
  });

  group('back', () {
    test('leaves the flow from the phone step', () {
      expect(cubit.back(), isFalse);
    });

    test('returns to the phone step with the number prefilled', () async {
      await toCodeStep();

      expect(cubit.back(), isTrue);
      expect(cubit.state, const ForgotPasswordEnterPhone(phone: '0512345678'));
    });

    test('returns from the new password to the code step', () async {
      await toNewPasswordStep();

      cubit.back();

      expect(cubit.state, const ForgotPasswordEnterCode(phone: _e164));
    });

    test('stays put while a request is in flight', () async {
      await toCodeStep();
      repository.gate = Completer<void>();
      final Future<void> verifying = cubit.verifyCode('1234');

      expect(cubit.back(), isTrue);
      expect(cubit.state, isA<ForgotPasswordEnterCode>());

      repository.gate!.complete();
      await verifying;
    });
  });
}
