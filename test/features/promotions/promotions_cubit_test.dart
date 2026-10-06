import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/features/promotions/domain/entities/store_promotion.dart';
import 'package:ssm/features/promotions/domain/repos/promotions_repository.dart';
import 'package:ssm/features/promotions/presentation/cubit/promotions_cubit.dart';
import 'package:ssm/features/promotions/presentation/cubit/promotions_state.dart';

import '../../helpers/fake_zone_repository.dart';

/// Each call waits on a completer the test answers, so ordering is explicit.
class _FakePromotionsRepository implements PromotionsRepository {
  final List<Completer<Either<Failure, List<StorePromotion>>>> calls = [];

  @override
  Future<Either<Failure, List<StorePromotion>>> getFeaturedPromotions({
    int page = 1,
    int limit = featuredPromotionsLimit,
  }) {
    final Completer<Either<Failure, List<StorePromotion>>> call = Completer();
    calls.add(call);
    return call.future;
  }
}

StorePromotion _promotion(int id) => StorePromotion(
  id: id,
  storeId: id * 10,
  bannerUrl: 'https://cdn.example.com/$id.webp',
);

void main() {
  late _FakePromotionsRepository repository;
  late FakeZoneRepository zone;
  late PromotionsCubit cubit;

  setUp(() {
    repository = _FakePromotionsRepository();
    zone = FakeZoneRepository();
    cubit = PromotionsCubit(
      promotionsRepository: repository,
      zoneRepository: zone,
    );
  });

  tearDown(() => cubit.close());

  void succeed(List<StorePromotion> promotions, {int call = -1}) => repository
      .calls[call < 0 ? repository.calls.length - 1 : call]
      .complete(Right<Failure, List<StorePromotion>>(promotions));

  void fail(Failure failure) => repository.calls.last.complete(
    Left<Failure, List<StorePromotion>>(failure),
  );

  Future<void> loaded(List<StorePromotion> promotions) async {
    final Future<void> load = cubit.load();
    succeed(promotions);
    await load;
  }

  test('starts in the initial state', () {
    expect(cubit.state, const PromotionsInitial());
  });

  test('shows loading, then the promotions', () async {
    final Future<void> load = cubit.load();
    expect(cubit.state, const PromotionsLoading());

    succeed(<StorePromotion>[_promotion(1), _promotion(2)]);
    await load;

    expect(
      cubit.state,
      PromotionsLoaded(<StorePromotion>[_promotion(1), _promotion(2)]),
    );
  });

  test('an empty answer is the empty state', () async {
    await loaded(const <StorePromotion>[]);

    expect(cubit.state, const PromotionsEmpty());
  });

  test('a failed first load is the error state', () async {
    final Future<void> load = cubit.load();
    fail(const ServerFailure());
    await load;

    expect(cubit.state, const PromotionsError(ServerFailure()));
  });

  test('a refresh keeps the banners on screen while it runs', () async {
    await loaded(<StorePromotion>[_promotion(1)]);

    final Future<void> refresh = cubit.load();
    expect(cubit.state, PromotionsLoaded(<StorePromotion>[_promotion(1)]));

    succeed(<StorePromotion>[_promotion(2)]);
    await refresh;
    expect(cubit.state, PromotionsLoaded(<StorePromotion>[_promotion(2)]));
  });

  test('a failed refresh keeps the banners', () async {
    await loaded(<StorePromotion>[_promotion(1)]);

    final Future<void> refresh = cubit.load();
    fail(const ServerFailure());
    await refresh;

    expect(cubit.state, PromotionsLoaded(<StorePromotion>[_promotion(1)]));
  });

  test('a refresh that finds none empties the slider', () async {
    await loaded(<StorePromotion>[_promotion(1)]);

    await loaded(const <StorePromotion>[]);

    expect(cubit.state, const PromotionsEmpty());
  });

  test('ignores a load while one is running', () async {
    final Future<void> first = cubit.load();
    await cubit.load();

    expect(repository.calls, hasLength(1));
    succeed(<StorePromotion>[_promotion(1)]);
    await first;
  });

  test('a new zone clears the old zone banners and reloads', () async {
    await loaded(<StorePromotion>[_promotion(1)]);

    zone.change(<int>[9]);

    expect(cubit.state, const PromotionsLoading());
    expect(repository.calls, hasLength(2));
  });

  test('a failed reload for a new zone shows the error state', () async {
    await loaded(<StorePromotion>[_promotion(1)]);

    zone.change(<int>[9]);
    fail(const ServerFailure());
    await pumpEventQueue();

    expect(cubit.state, const PromotionsError(ServerFailure()));
  });

  test('drops an old zone answer that arrives after the new one', () async {
    final Future<void> oldZone = cubit.load();
    zone.change(<int>[9]);

    succeed(<StorePromotion>[_promotion(2)], call: 1);
    await pumpEventQueue();
    succeed(<StorePromotion>[_promotion(1)], call: 0);
    await oldZone;

    expect(cubit.state, PromotionsLoaded(<StorePromotion>[_promotion(2)]));
  });

  test('stops reloading for zone changes once closed', () async {
    await cubit.close();

    zone.change(<int>[9]);

    expect(repository.calls, isEmpty);
  });
}
