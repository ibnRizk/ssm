import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:ssm/core/api/api_endpoints.dart';
import 'package:ssm/core/error/exceptions.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/features/account/data/datasources/account_remote_data_source.dart';
import 'package:ssm/features/account/data/models/customer_profile_model.dart';
import 'package:ssm/features/account/data/models/requests/update_profile_request.dart';
import 'package:ssm/features/account/data/repos/account_repository_impl.dart';
import 'package:ssm/features/account/domain/entities/customer_profile.dart';
import 'package:ssm/features/account/domain/repos/account_repository.dart';
import 'package:ssm/features/account/presentation/cubit/edit_profile_cubit.dart';
import 'package:ssm/features/account/presentation/cubit/edit_profile_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_dio_consumer.dart';

final CustomerProfile _current = CustomerProfile(
  name: 'Sara Customer',
  phone: '+966512345678',
  email: 'old@example.com',
  createdAt: DateTime.utc(2025, 3, 14),
);

class _FakeAccountRepository implements AccountRepository {
  Completer<Either<Failure, Unit>> pending = Completer<Either<Failure, Unit>>();
  final List<ProfileUpdate> updates = <ProfileUpdate>[];

  @override
  Future<Either<Failure, CustomerProfile>> getProfile() =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> updateProfile(ProfileUpdate update) {
    updates.add(update);
    return pending.future;
  }
}

void main() {
  group('POST /customer/update-profile', () {
    test('sends one name field with email and phone', () async {
      final FakeDioConsumer consumer = FakeDioConsumer(
        response: <String, dynamic>{'message': 'ok'},
      );

      await AccountRemoteDataSourceImpl(consumer: consumer).updateProfile(
        UpdateProfileRequest.fromUpdate(
          const ProfileUpdate(
            name: 'Sara Customer',
            phone: '+966512345678',
            email: 'sara@example.com',
          ),
        ),
      );

      expect(consumer.lastVerb, 'POST');
      expect(consumer.lastPath, ApiEndpoints.updateProfile);
      expect(consumer.lastBody, <String, dynamic>{
        'name': 'Sara Customer',
        'email': 'sara@example.com',
        'phone': '+966512345678',
      });
    });

    test('a duplicate email maps to ForbiddenFailure with its code', () async {
      final FakeDioConsumer consumer = FakeDioConsumer()
        ..error = const ForbiddenException(
          message: 'The email has already been taken.',
          code: 'email',
        );

      final Either<Failure, Unit> result =
          await AccountRepositoryImpl(
            remote: AccountRemoteDataSourceImpl(consumer: consumer),
          ).updateProfile(
            const ProfileUpdate(
              name: 'A B',
              phone: '+966512345678',
              email: 'x',
            ),
          );

      expect(
        result,
        const Left<Failure, Unit>(
          ForbiddenFailure(
            message: 'The email has already been taken.',
            code: 'email',
          ),
        ),
      );
    });
  });

  group('CustomerProfileModel email', () {
    test('reads email when present', () {
      final CustomerProfile profile = CustomerProfileModel.fromJson(
        <String, dynamic>{'phone': '+966512345678', 'email': 'sara@x.com'},
      );

      expect(profile.email, 'sara@x.com');
    });

    test('is null when absent', () {
      final CustomerProfile profile = CustomerProfileModel.fromJson(
        <String, dynamic>{'phone': '+966512345678'},
      );

      expect(profile.email, isNull);
    });
  });

  group('EditProfileCubit', () {
    late _FakeAccountRepository repository;
    late EditProfileCubit cubit;

    setUp(() {
      repository = _FakeAccountRepository();
      cubit = EditProfileCubit(repository: repository);
    });

    tearDown(() => cubit.close());

    Future<void> submit() => cubit.submit(
      current: _current,
      name: '  Sara   Edited ',
      phone: '0598765432',
      email: ' new@example.com ',
    );

    test('normalises the form input before sending', () async {
      final Future<void> pending = submit();
      repository.pending.complete(const Right<Failure, Unit>(unit));
      await pending;

      expect(
        repository.updates.single,
        const ProfileUpdate(
          name: 'Sara Edited',
          phone: '+966598765432',
          email: 'new@example.com',
        ),
      );
    });

    test(
      'success carries the updated profile, keeping the join date',
      () async {
        final Future<void> pending = submit();
        repository.pending.complete(const Right<Failure, Unit>(unit));
        await pending;

        expect(
          cubit.state,
          EditProfileSuccess(
            CustomerProfile(
              name: 'Sara Edited',
              phone: '+966598765432',
              email: 'new@example.com',
              createdAt: DateTime.utc(2025, 3, 14),
            ),
          ),
        );
      },
    );

    test('emits the failure when the update is refused', () async {
      final Future<void> pending = submit();
      repository.pending.complete(
        const Left<Failure, Unit>(ForbiddenFailure(code: 'email')),
      );
      await pending;

      expect(
        cubit.state,
        const EditProfileError(ForbiddenFailure(code: 'email')),
      );
    });

    test('ignores a second submit while one is in flight', () async {
      final Future<void> first = submit();
      await submit();
      repository.pending.complete(const Right<Failure, Unit>(unit));
      await first;

      expect(repository.updates, hasLength(1));
    });
  });
}
