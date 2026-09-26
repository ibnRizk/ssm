import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_base/core/error/failures.dart';
import 'package:flutter_base/features/account/domain/entities/customer_profile.dart';
import 'package:flutter_base/features/account/domain/repos/account_repository.dart';
import 'package:flutter_base/features/account/presentation/cubit/profile_cubit.dart';
import 'package:flutter_base/features/account/presentation/cubit/profile_state.dart';
import 'package:flutter_base/features/loyalty/domain/entities/loyalty_history.dart';
import 'package:flutter_base/features/loyalty/domain/entities/loyalty_progress.dart';
import 'package:flutter_base/features/loyalty/domain/repos/loyalty_repository.dart';
import 'package:flutter_test/flutter_test.dart';

const CustomerProfile _profile = CustomerProfile(
  name: 'Sara Customer',
  phone: '+966512345678',
);

const LoyaltyProgress _loyalty = LoyaltyProgress(
  currentProgress: 7,
  eligibleOrdersRequired: 10,
  ordersRemainingForNextReward: 3,
  availableFreeDeliveries: 0,
);

/// Each fake answers through a [Completer] the test controls, so ordering
/// and concurrency are explicit rather than timing-dependent.
class _FakeAccountRepository implements AccountRepository {
  Completer<Either<Failure, CustomerProfile>> pending =
      Completer<Either<Failure, CustomerProfile>>();
  int calls = 0;

  @override
  Future<Either<Failure, CustomerProfile>> getProfile() {
    calls++;
    return pending.future;
  }

  @override
  Future<Either<Failure, Unit>> updateProfile(ProfileUpdate update) =>
      throw UnimplementedError();
}

class _FakeLoyaltyRepository implements LoyaltyRepository {
  Completer<Either<Failure, LoyaltyProgress>> pending =
      Completer<Either<Failure, LoyaltyProgress>>();
  int calls = 0;

  @override
  Future<Either<Failure, LoyaltyProgress>> getProgress() {
    calls++;
    return pending.future;
  }

  @override
  Future<Either<Failure, LoyaltyHistory>> getHistory() =>
      throw UnimplementedError();
}

void main() {
  late _FakeAccountRepository account;
  late _FakeLoyaltyRepository loyalty;
  late ProfileCubit cubit;

  setUp(() {
    account = _FakeAccountRepository();
    loyalty = _FakeLoyaltyRepository();
    cubit = ProfileCubit(
      accountRepository: account,
      loyaltyRepository: loyalty,
    );
  });

  tearDown(() => cubit.close());

  test('starts both requests before either completes', () async {
    unawaited(cubit.load());
    await Future<void>.delayed(Duration.zero);

    expect(account.calls, 1);
    expect(loyalty.calls, 1);
    expect(cubit.state, const ProfileLoading());
  });

  test('emits loading then the profile with loyalty', () async {
    final Future<void> expectation = expectLater(
      cubit.stream,
      emitsInOrder(<ProfileState>[
        const ProfileLoading(),
        const ProfileLoaded(profile: _profile, loyalty: _loyalty),
      ]),
    );

    final Future<void> load = cubit.load();
    account.pending.complete(const Right<Failure, CustomerProfile>(_profile));
    loyalty.pending.complete(const Right<Failure, LoyaltyProgress>(_loyalty));
    await load;
    await expectation;
  });

  test('still shows the profile when only loyalty fails', () async {
    final Future<void> load = cubit.load();
    account.pending.complete(const Right<Failure, CustomerProfile>(_profile));
    loyalty.pending.complete(
      const Left<Failure, LoyaltyProgress>(ServerFailure()),
    );
    await load;

    expect(cubit.state, const ProfileLoaded(profile: _profile));
  });

  test('emits the failure when the profile fails', () async {
    final Future<void> load = cubit.load();
    account.pending.complete(
      const Left<Failure, CustomerProfile>(UnauthorizedFailure()),
    );
    loyalty.pending.complete(const Right<Failure, LoyaltyProgress>(_loyalty));
    await load;

    expect(cubit.state, const ProfileError(UnauthorizedFailure()));
  });

  test('a refresh keeps the loaded profile on screen', () async {
    final Future<void> first = cubit.load();
    account.pending.complete(const Right<Failure, CustomerProfile>(_profile));
    loyalty.pending.complete(const Right<Failure, LoyaltyProgress>(_loyalty));
    await first;

    account.pending = Completer<Either<Failure, CustomerProfile>>();
    loyalty.pending = Completer<Either<Failure, LoyaltyProgress>>();
    final List<ProfileState> emitted = <ProfileState>[];
    final StreamSubscription<ProfileState> sub = cubit.stream.listen(
      emitted.add,
    );

    final Future<void> refresh = cubit.load();
    account.pending.complete(const Right<Failure, CustomerProfile>(_profile));
    loyalty.pending.complete(const Right<Failure, LoyaltyProgress>(_loyalty));
    await refresh;
    await sub.cancel();

    expect(emitted, isNot(contains(const ProfileLoading())));
  });

  test('ignores a second load while one is in flight', () async {
    final Future<void> first = cubit.load();
    await cubit.load();
    account.pending.complete(const Right<Failure, CustomerProfile>(_profile));
    loyalty.pending.complete(const Right<Failure, LoyaltyProgress>(_loyalty));
    await first;

    expect(account.calls, 1);
    expect(loyalty.calls, 1);
  });

  group('profileUpdated', () {
    const CustomerProfile edited = CustomerProfile(
      name: 'Sara Edited',
      phone: '+966598765432',
      email: 'sara@example.com',
    );

    test('replaces the profile and keeps the loyalty progress', () async {
      final Future<void> load = cubit.load();
      account.pending.complete(const Right<Failure, CustomerProfile>(_profile));
      loyalty.pending.complete(const Right<Failure, LoyaltyProgress>(_loyalty));
      await load;

      cubit.profileUpdated(edited);

      expect(
        cubit.state,
        const ProfileLoaded(profile: edited, loyalty: _loyalty),
      );
    });

    test('shows the profile even before the first load finished', () {
      cubit.profileUpdated(edited);

      expect(cubit.state, const ProfileLoaded(profile: edited));
    });

    test('is ignored once the cubit is closed', () async {
      await cubit.close();

      expect(() => cubit.profileUpdated(edited), returnsNormally);
    });
  });
}
