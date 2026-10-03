import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/api/api_endpoints.dart';
import 'package:ssm/core/error/exceptions.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/features/account/data/datasources/account_remote_data_source.dart';
import 'package:ssm/features/account/data/repos/account_repository_impl.dart';
import 'package:ssm/features/account/domain/entities/customer_profile.dart';
import 'package:ssm/features/account/domain/repos/account_repository.dart';
import 'package:ssm/features/account/presentation/cubit/delete_account_cubit.dart';
import 'package:ssm/features/account/presentation/cubit/delete_account_state.dart';
import 'package:ssm/features/auth/domain/entities/login_credentials.dart';
import 'package:ssm/features/auth/domain/entities/registration_details.dart';
import 'package:ssm/features/auth/domain/repos/auth_repository.dart';

import '../../helpers/fake_dio_consumer.dart';

/// `remove-account`'s refusal: HTTP 203 with an errors body.
const Map<String, dynamic> _ongoingOrderBody = <String, dynamic>{
  'errors': <dynamic>[
    <String, dynamic>{
      'code': 'on-going',
      'message': 'You have an ongoing order',
    },
  ],
};

class _FakeAccountRepository implements AccountRepository {
  Either<Failure, Unit> result = const Right<Failure, Unit>(unit);
  Completer<void>? gate;
  int deleteCalls = 0;

  @override
  Future<Either<Failure, Unit>> deleteAccount() async {
    deleteCalls++;
    await gate?.future;
    return result;
  }

  @override
  Future<Either<Failure, CustomerProfile>> getProfile() =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> updateProfile(ProfileUpdate update) =>
      throw UnimplementedError();
}

class _FakeAuthRepository implements AuthRepository {
  int logoutCalls = 0;

  @override
  Future<Either<Failure, Unit>> logout() async {
    logoutCalls++;
    return const Right<Failure, Unit>(unit);
  }

  @override
  Future<Either<Failure, Unit>> login(LoginCredentials credentials) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> register(RegistrationDetails details) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> requestPasswordReset(String phone) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> verifyPasswordResetCode({
    required String phone,
    required String code,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String phone,
    required String code,
    required String password,
  }) => throw UnimplementedError();
}

void main() {
  group('data', () {
    test('sends a DELETE to remove-account', () async {
      final FakeDioConsumer consumer = FakeDioConsumer(response: <dynamic>[]);

      await AccountRemoteDataSourceImpl(consumer: consumer).deleteAccount();

      expect(consumer.lastVerb, 'DELETE');
      expect(consumer.lastPath, ApiEndpoints.removeAccount);
    });

    test('the 203 ongoing-order body is thrown as a refusal', () {
      final FakeDioConsumer consumer = FakeDioConsumer(
        response: _ongoingOrderBody,
      );

      expect(
        AccountRemoteDataSourceImpl(consumer: consumer).deleteAccount(),
        throwsA(isA<ForbiddenException>()),
      );
    });

    test('the repository reports it with the on-going code', () async {
      final AccountRepositoryImpl repository = AccountRepositoryImpl(
        remote: AccountRemoteDataSourceImpl(
          consumer: FakeDioConsumer(response: _ongoingOrderBody),
        ),
      );

      final Either<Failure, Unit> result = await repository.deleteAccount();

      expect(
        result,
        const Left<Failure, Unit>(
          ForbiddenFailure(
            message: 'You have an ongoing order',
            code: AccountRefusalCode.ongoingOrder,
          ),
        ),
      );
    });
  });

  group('DeleteAccountCubit', () {
    late _FakeAccountRepository accounts;
    late _FakeAuthRepository auth;
    late DeleteAccountCubit cubit;

    setUp(() {
      accounts = _FakeAccountRepository();
      auth = _FakeAuthRepository();
      cubit = DeleteAccountCubit(
        accountRepository: accounts,
        authRepository: auth,
      );
    });

    tearDown(() => cubit.close());

    test('emits in progress then done on success', () async {
      final Future<void> expectation = expectLater(
        cubit.stream,
        emitsInOrder(<DeleteAccountState>[
          const DeleteAccountInProgress(),
          const DeleteAccountDone(),
        ]),
      );

      await cubit.deleteAccount();
      await expectation;
    });

    test('signs out locally once the account is deleted', () async {
      await cubit.deleteAccount();

      expect(auth.logoutCalls, 1);
    });

    test('reports the ongoing-order refusal', () async {
      const ForbiddenFailure refusal = ForbiddenFailure(
        code: AccountRefusalCode.ongoingOrder,
      );
      accounts.result = const Left<Failure, Unit>(refusal);

      await cubit.deleteAccount();

      expect(cubit.state, const DeleteAccountError(refusal));
    });

    test('stays signed in when the deletion is refused', () async {
      accounts.result = const Left<Failure, Unit>(
        ForbiddenFailure(code: AccountRefusalCode.ongoingOrder),
      );

      await cubit.deleteAccount();

      expect(auth.logoutCalls, 0);
    });

    test('ignores a second tap while the first is in flight', () async {
      accounts.gate = Completer<void>();

      final Future<void> first = cubit.deleteAccount();
      await cubit.deleteAccount();
      accounts.gate!.complete();
      await first;

      expect(accounts.deleteCalls, 1);
    });

    test('still signs out if the screen closed mid-request', () async {
      accounts.gate = Completer<void>();

      final Future<void> deleting = cubit.deleteAccount();
      await cubit.close();
      accounts.gate!.complete();
      await deleting;

      expect(auth.logoutCalls, 1);
    });
  });
}
