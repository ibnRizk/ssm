import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/features/subscriptions/domain/entities/active_subscription.dart';
import 'package:ssm/features/subscriptions/domain/entities/delivery_zone.dart';
import 'package:ssm/features/subscriptions/domain/entities/subscription_plan.dart';
import 'package:ssm/features/subscriptions/domain/repos/subscriptions_repository.dart';
import 'package:ssm/features/subscriptions/presentation/cubit/subscriptions_cubit.dart';
import 'package:ssm/features/subscriptions/presentation/cubit/subscriptions_state.dart';
import 'package:flutter_test/flutter_test.dart';

const DeliveryZone _turbah = DeliveryZone(id: 1, name: 'تربة');
const DeliveryZone _alawah = DeliveryZone(id: 2, name: 'العلاوة');

const SubscriptionPlan _monthly = SubscriptionPlan(
  id: 10,
  name: 'Monthly',
  deliveriesCount: 11,
  validityDays: 30,
  price: 100,
  currency: 'SAR',
);

const SubscriptionPlan _golden = SubscriptionPlan(
  id: 40,
  name: 'Golden',
  deliveriesCount: 44,
  validityDays: 120,
  price: 400,
  currency: 'SAR',
);

const ActiveSubscription _active = ActiveSubscription(
  id: 9,
  deliveriesTotal: 11,
  deliveriesRemaining: 7,
);

/// Every call answers through a [Completer] the test controls, so ordering
/// (and the stale-response race) is explicit rather than timing-dependent.
class _FakeRepository implements SubscriptionsRepository {
  Completer<Either<Failure, List<DeliveryZone>>> zones =
      Completer<Either<Failure, List<DeliveryZone>>>();
  Completer<Either<Failure, ActiveSubscription?>> current =
      Completer<Either<Failure, ActiveSubscription?>>();
  final Map<int, Completer<Either<Failure, List<SubscriptionPlan>>>> plans =
      <int, Completer<Either<Failure, List<SubscriptionPlan>>>>{};
  Completer<Either<Failure, Unit>> purchase =
      Completer<Either<Failure, Unit>>();

  int zonesCalls = 0;
  int currentCalls = 0;
  final List<int> planRequests = <int>[];
  final List<int> purchaseRequests = <int>[];

  Completer<Either<Failure, List<SubscriptionPlan>>> plansFor(int zoneId) =>
      plans.putIfAbsent(
        zoneId,
        () => Completer<Either<Failure, List<SubscriptionPlan>>>(),
      );

  @override
  Future<Either<Failure, List<DeliveryZone>>> getZones() {
    zonesCalls++;
    return zones.future;
  }

  @override
  Future<Either<Failure, ActiveSubscription?>> getCurrentSubscription() {
    currentCalls++;
    return current.future;
  }

  @override
  Future<Either<Failure, List<SubscriptionPlan>>> getPlans(int zoneId) {
    planRequests.add(zoneId);
    return plansFor(zoneId).future;
  }

  @override
  Future<Either<Failure, Unit>> createPurchaseIntent(int planId) {
    purchaseRequests.add(planId);
    return purchase.future;
  }

  /// Answers the zones + current pair and resets them for a next load.
  void answerInit({
    Either<Failure, List<DeliveryZone>> zones = const Right(<DeliveryZone>[
      _turbah,
      _alawah,
    ]),
    Either<Failure, ActiveSubscription?> current = const Right(null),
  }) {
    this.zones.complete(zones);
    this.current.complete(current);
  }

  void resetInit() {
    zones = Completer<Either<Failure, List<DeliveryZone>>>();
    current = Completer<Either<Failure, ActiveSubscription?>>();
  }
}

void main() {
  late _FakeRepository repository;
  late SubscriptionsCubit cubit;

  setUp(() {
    repository = _FakeRepository();
    cubit = SubscriptionsCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  SubscriptionsLoaded loaded() => cubit.state as SubscriptionsLoaded;

  /// Loads zones [_turbah, _alawah] and Turbah's plans.
  Future<void> loadTurbah({
    List<SubscriptionPlan> plans = const <SubscriptionPlan>[_monthly, _golden],
  }) async {
    final Future<void> load = cubit.load();
    repository.answerInit();
    await Future<void>.delayed(Duration.zero);
    repository.plansFor(1).complete(Right(plans));
    await load;
  }

  group('load', () {
    test('requests zones and current subscription concurrently', () async {
      unawaited(cubit.load());
      await Future<void>.delayed(Duration.zero);

      expect(repository.zonesCalls, 1);
      expect(repository.currentCalls, 1);
      expect(cubit.state, const SubscriptionsLoading());
    });

    test('selects the first zone and fetches its plans', () async {
      await loadTurbah();

      expect(repository.planRequests, <int>[1]);
      expect(
        loaded(),
        const SubscriptionsLoaded(
          zones: <DeliveryZone>[_turbah, _alawah],
          selectedZoneId: 1,
          plans: PlansLoaded(<SubscriptionPlan>[
            _monthly,
            _golden,
          ], bestValueId: 40),
        ),
      );
    });

    test('shows the active subscription', () async {
      final Future<void> load = cubit.load();
      repository.answerInit(current: const Right(_active));
      await Future<void>.delayed(Duration.zero);
      repository.plansFor(1).complete(const Right(<SubscriptionPlan>[]));
      await load;

      expect(loaded().current, _active);
    });

    test('a failed current-subscription call only hides the banner', () async {
      final Future<void> load = cubit.load();
      repository.answerInit(current: const Left(ServerFailure()));
      await Future<void>.delayed(Duration.zero);
      repository.plansFor(1).complete(const Right(<SubscriptionPlan>[]));
      await load;

      expect(loaded().current, isNull);
      expect(loaded().selectedZoneId, 1);
    });

    test('emits the failure when zones fail', () async {
      final Future<void> load = cubit.load();
      repository.answerInit(zones: const Left(NetworkFailure()));
      await load;

      expect(cubit.state, const SubscriptionsError(NetworkFailure()));
      expect(repository.planRequests, isEmpty);
    });

    test('no zones means no selection and no plan request', () async {
      final Future<void> load = cubit.load();
      repository.answerInit(zones: const Right(<DeliveryZone>[]));
      await load;

      expect(loaded().selectedZoneId, isNull);
      expect(loaded().plans, const PlansLoaded(<SubscriptionPlan>[]));
      expect(repository.planRequests, isEmpty);
    });

    test('a refresh keeps the selected zone', () async {
      await loadTurbah();
      final Future<void> select = cubit.selectZone(2);
      repository.plansFor(2).complete(const Right(<SubscriptionPlan>[]));
      await select;

      repository.resetInit();
      repository.plans.remove(2);
      final Future<void> refresh = cubit.load();
      repository.answerInit();
      await Future<void>.delayed(Duration.zero);
      repository.plansFor(2).complete(const Right(<SubscriptionPlan>[]));
      await refresh;

      expect(loaded().selectedZoneId, 2);
    });
  });

  group('selectZone', () {
    test('switches zone and fetches its plans', () async {
      await loadTurbah();

      final Future<void> select = cubit.selectZone(2);
      expect(loaded().selectedZoneId, 2);
      expect(loaded().plans, const PlansLoading());

      repository
          .plansFor(2)
          .complete(const Right(<SubscriptionPlan>[_monthly]));
      await select;

      expect(loaded().plans, const PlansLoaded(<SubscriptionPlan>[_monthly]));
    });

    test('drops a stale answer from the previous zone', () async {
      final Future<void> load = cubit.load();
      repository.answerInit();
      await Future<void>.delayed(Duration.zero);

      // Switch before Turbah's plans arrive; Turbah then answers late.
      final Future<void> select = cubit.selectZone(2);
      repository.plansFor(2).complete(const Right(<SubscriptionPlan>[_golden]));
      await select;
      repository
          .plansFor(1)
          .complete(const Right(<SubscriptionPlan>[_monthly]));
      await load;

      expect(loaded().selectedZoneId, 2);
      expect(loaded().plans, const PlansLoaded(<SubscriptionPlan>[_golden]));
    });

    test('selecting the current zone does nothing', () async {
      await loadTurbah();

      await cubit.selectZone(1);

      expect(repository.planRequests, <int>[1]);
    });

    test('a failed plans load can be retried', () async {
      await loadTurbah();
      final Future<void> select = cubit.selectZone(2);
      repository.plansFor(2).complete(const Left(NetworkFailure()));
      await select;
      expect(loaded().plans, const PlansError(NetworkFailure()));

      repository.plans.remove(2);
      final Future<void> retry = cubit.retryPlans();
      repository
          .plansFor(2)
          .complete(const Right(<SubscriptionPlan>[_monthly]));
      await retry;

      expect(loaded().plans, const PlansLoaded(<SubscriptionPlan>[_monthly]));
    });
  });

  group('subscribe', () {
    test('a 201 intent is reported as pending approval', () async {
      await loadTurbah();

      final Future<void> subscribe = cubit.subscribe(_golden.id);
      expect(loaded().purchase, const PurchaseInProgress(40));

      repository.purchase.complete(const Right<Failure, Unit>(unit));
      await subscribe;

      expect(repository.purchaseRequests, <int>[40]);
      expect(loaded().purchase, const PurchasePendingApproval(40));
    });

    test('reports a refused intent', () async {
      await loadTurbah();

      final Future<void> subscribe = cubit.subscribe(999);
      repository.purchase.complete(
        const Left<Failure, Unit>(ServerFailure(message: 'Plan not found')),
      );
      await subscribe;

      expect(
        loaded().purchase,
        const PurchaseFailed(ServerFailure(message: 'Plan not found')),
      );
    });

    test('ignores a second subscribe while one is in flight', () async {
      await loadTurbah();

      final Future<void> first = cubit.subscribe(_monthly.id);
      await cubit.subscribe(_golden.id);
      repository.purchase.complete(const Right<Failure, Unit>(unit));
      await first;

      expect(repository.purchaseRequests, <int>[10]);
    });

    test('does nothing before the screen has loaded', () async {
      await cubit.subscribe(_monthly.id);

      expect(repository.purchaseRequests, isEmpty);
    });
  });
}
