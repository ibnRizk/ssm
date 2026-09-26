import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_base/core/error/failures.dart';
import 'package:flutter_base/features/auth/domain/entities/login_credentials.dart';
import 'package:flutter_base/features/auth/domain/entities/registration_details.dart';
import 'package:flutter_base/features/auth/domain/repos/auth_repository.dart';
import 'package:flutter_base/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_base/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository implements AuthRepository {
  Either<Failure, Unit> result = const Right<Failure, Unit>(unit);
  final List<LoginCredentials> logins = <LoginCredentials>[];
  final List<RegistrationDetails> registrations = <RegistrationDetails>[];

  /// When set, calls wait on it — lets a test observe the loading state.
  Completer<void>? gate;

  @override
  Future<Either<Failure, Unit>> login(LoginCredentials credentials) async {
    logins.add(credentials);
    await gate?.future;
    return result;
  }

  @override
  Future<Either<Failure, Unit>> register(RegistrationDetails details) async {
    registrations.add(details);
    await gate?.future;
    return result;
  }

  int logoutCalls = 0;

  @override
  Future<Either<Failure, Unit>> logout() async {
    logoutCalls++;
    await gate?.future;
    return result;
  }
}

void main() {
  late _FakeRepository repository;
  late AuthCubit cubit;

  setUp(() {
    repository = _FakeRepository();
    cubit = AuthCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  test('starts in AuthInitial', () {
    expect(cubit.state, const AuthInitial());
  });

  group('logout', () {
    test('emits loading then unauthenticated', () async {
      final Future<void> expectation = expectLater(
        cubit.stream,
        emitsInOrder(<AuthState>[
          const AuthLoading(),
          const AuthUnauthenticated(),
        ]),
      );

      await cubit.logout();
      await expectation;
    });

    test('emits the failure and stays signed in when storage fails', () async {
      repository.result = const Left<Failure, Unit>(CacheFailure());
      final Future<void> expectation = expectLater(
        cubit.stream,
        emitsInOrder(<AuthState>[
          const AuthLoading(),
          const AuthError(CacheFailure()),
        ]),
      );

      await cubit.logout();
      await expectation;
    });

    test('ignores a second tap while the first is in flight', () async {
      repository.gate = Completer<void>();

      final Future<void> first = cubit.logout();
      await cubit.logout();
      repository.gate!.complete();
      await first;

      expect(repository.logoutCalls, 1);
    });
  });

  group('login', () {
    test('emits loading then success', () async {
      final Future<void> expectation = expectLater(
        cubit.stream,
        emitsInOrder(<AuthState>[const AuthLoading(), const AuthSuccess()]),
      );

      await cubit.login(phone: '0512345678', password: 'secret123');
      await expectation;
    });

    test('emits loading then the failure', () async {
      repository.result = const Left<Failure, Unit>(UnauthorizedFailure());
      final Future<void> expectation = expectLater(
        cubit.stream,
        emitsInOrder(<AuthState>[
          const AuthLoading(),
          const AuthError(UnauthorizedFailure()),
        ]),
      );

      await cubit.login(phone: '0512345678', password: 'wrong');
      await expectation;
    });

    test('sends the phone in E.164 form', () async {
      await cubit.login(phone: '05 1234 5678', password: 'secret123');

      expect(
        repository.logins.single,
        const LoginCredentials(phone: '+966512345678', password: 'secret123'),
      );
    });

    test('ignores a second submit while the first is in flight', () async {
      repository.gate = Completer<void>();

      final Future<void> first = cubit.login(
        phone: '0512345678',
        password: 'secret123',
      );
      await cubit.login(phone: '0512345678', password: 'secret123');
      repository.gate!.complete();
      await first;

      expect(repository.logins, hasLength(1));
    });
  });

  group('register', () {
    test('normalises name, phone and email before sending', () async {
      await cubit.register(
        name: '  Sara   Customer ',
        phone: '0512345678',
        email: ' sara@ssm.test ',
        password: 'secret123',
      );

      expect(
        repository.registrations.single,
        const RegistrationDetails(
          name: 'Sara Customer',
          phone: '+966512345678',
          email: 'sara@ssm.test',
          password: 'secret123',
        ),
      );
    });

    test('emits loading then the duplicate-phone failure', () async {
      const ForbiddenFailure failure = ForbiddenFailure(
        message: 'The phone has already been taken.',
        code: 'phone',
      );
      repository.result = const Left<Failure, Unit>(failure);
      final Future<void> expectation = expectLater(
        cubit.stream,
        emitsInOrder(<AuthState>[
          const AuthLoading(),
          const AuthError(failure),
        ]),
      );

      await cubit.register(
        name: 'Sara Customer',
        phone: '0512345678',
        email: 'sara@ssm.test',
        password: 'secret123',
      );
      await expectation;
    });
  });
}
