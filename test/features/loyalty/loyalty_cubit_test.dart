import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:ssm/core/api/api_endpoints.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/features/loyalty/data/datasources/loyalty_remote_data_source.dart';
import 'package:ssm/features/loyalty/domain/entities/loyalty_history.dart';
import 'package:ssm/features/loyalty/domain/entities/loyalty_progress.dart';
import 'package:ssm/features/loyalty/domain/repos/loyalty_repository.dart';
import 'package:ssm/features/loyalty/presentation/cubit/loyalty_cubit.dart';
import 'package:ssm/features/loyalty/presentation/cubit/loyalty_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_dio_consumer.dart';

const LoyaltyProgress _progress = LoyaltyProgress(
  currentProgress: 7,
  eligibleOrdersRequired: 10,
  ordersRemainingForNextReward: 3,
  availableFreeDeliveries: 1,
);

const LoyaltyHistory _history = LoyaltyHistory(total: 7, recentCount: 7);

/// Answers through [Completer]s the test controls, so ordering is explicit
/// rather than timing-dependent.
class _FakeLoyaltyRepository implements LoyaltyRepository {
  Completer<Either<Failure, LoyaltyProgress>> progress =
      Completer<Either<Failure, LoyaltyProgress>>();
  Completer<Either<Failure, LoyaltyHistory>> history =
      Completer<Either<Failure, LoyaltyHistory>>();
  int progressCalls = 0;

  @override
  Future<Either<Failure, LoyaltyProgress>> getProgress() {
    progressCalls++;
    return progress.future;
  }

  @override
  Future<Either<Failure, LoyaltyHistory>> getHistory() => history.future;

  void answer({
    Either<Failure, LoyaltyProgress> progress = const Right(_progress),
    Either<Failure, LoyaltyHistory> history = const Right(_history),
  }) {
    this.progress.complete(progress);
    this.history.complete(history);
  }
}

void main() {
  late _FakeLoyaltyRepository repository;
  late LoyaltyCubit cubit;

  setUp(() {
    repository = _FakeLoyaltyRepository();
    cubit = LoyaltyCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  test('emits loading then progress with history', () async {
    final Future<void> expectation = expectLater(
      cubit.stream,
      emitsInOrder(<LoyaltyState>[
        const LoyaltyLoading(),
        const LoyaltyLoaded(progress: _progress, history: _history),
      ]),
    );

    final Future<void> load = cubit.load();
    repository.answer();
    await load;
    await expectation;
  });

  test('still shows progress when only history fails', () async {
    final Future<void> load = cubit.load();
    repository.answer(history: const Left(ServerFailure()));
    await load;

    expect(cubit.state, const LoyaltyLoaded(progress: _progress));
  });

  test('emits the failure when progress fails', () async {
    final Future<void> load = cubit.load();
    repository.answer(progress: const Left(NetworkFailure()));
    await load;

    expect(cubit.state, const LoyaltyError(NetworkFailure()));
  });

  test('ignores a second load while one is in flight', () async {
    final Future<void> first = cubit.load();
    await cubit.load();
    repository.answer();
    await first;

    expect(repository.progressCalls, 1);
  });

  test('history is read from the dedicated endpoint', () async {
    final FakeDioConsumer consumer = FakeDioConsumer(
      response: <String, dynamic>{'data': <dynamic>[]},
    );

    await LoyaltyRemoteDataSourceImpl(consumer: consumer).getHistory();

    expect(consumer.lastPath, ApiEndpoints.loyaltyHistory);
  });
}
