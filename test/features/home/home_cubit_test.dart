import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/features/account/domain/entities/customer_profile.dart';
import 'package:ssm/features/account/domain/repos/account_repository.dart';
import 'package:ssm/features/catalog/domain/entities/catalog_category.dart';
import 'package:ssm/features/home/presentation/cubit/home_cubit.dart';
import 'package:ssm/features/home/presentation/cubit/home_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_catalog_repository.dart';
import '../../helpers/fake_zone_repository.dart';

class _FakeAccountRepository implements AccountRepository {
  final List<Completer<Either<Failure, CustomerProfile>>> calls = [];

  @override
  Future<Either<Failure, CustomerProfile>> getProfile() {
    final Completer<Either<Failure, CustomerProfile>> call = Completer();
    calls.add(call);
    return call.future;
  }

  @override
  Future<Either<Failure, Unit>> updateProfile(ProfileUpdate update) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> deleteAccount() => throw UnimplementedError();
}

const CustomerProfile _profile = CustomerProfile(
  name: 'Sara Customer',
  phone: '+966512345678',
);

const List<CatalogCategory> _categories = <CatalogCategory>[
  CatalogCategory(id: 1, name: 'Burgers'),
];

void main() {
  late _FakeAccountRepository account;
  late FakeCatalogRepository catalog;
  late FakeZoneRepository zone;
  late HomeCubit cubit;

  setUp(() {
    account = _FakeAccountRepository();
    catalog = FakeCatalogRepository();
    zone = FakeZoneRepository();
    cubit = HomeCubit(
      accountRepository: account,
      catalogRepository: catalog,
      zoneRepository: zone,
    );
  });

  tearDown(() => cubit.close());

  /// Answers the latest round of the three concurrent calls.
  Future<void> answer({
    Either<Failure, CustomerProfile> profile = const Right(_profile),
    Failure? catalogFailure,
  }) async {
    account.calls.last.complete(profile);
    if (catalogFailure == null) {
      catalog.categoryCalls.last.succeed(_categories);
      catalog.storeCalls.last.succeed(storesPage(<int>[1, 2], total: 9));
    } else {
      catalog.categoryCalls.last.fail(catalogFailure);
      catalog.storeCalls.last.succeed(storesPage(<int>[1], total: 1));
    }
  }

  test('loads the greeting name, categories and a stores preview', () async {
    final Future<void> load = cubit.load();
    expect(cubit.state, const HomeLoading());
    expect(catalog.storeCalls.single.page, 1);

    await answer();
    await load;

    expect(
      cubit.state,
      HomeLoaded(
        customerName: 'Sara',
        categories: _categories,
        stores: <int>[1, 2].map(fakeStore).toList(),
        zoneIds: const <int>[8],
      ),
    );
  });

  test('a failed profile only makes the greeting generic', () async {
    final Future<void> load = cubit.load();
    await answer(profile: const Left(ServerFailure()));
    await load;

    final HomeState state = cubit.state;
    expect(state, isA<HomeLoaded>());
    expect((state as HomeLoaded).customerName, isNull);
  });

  test('a failed catalog call is an error on first load', () async {
    final Future<void> load = cubit.load();
    await answer(catalogFailure: const NetworkFailure());
    await load;

    expect(cubit.state, const HomeError(NetworkFailure()));
  });

  test('a failed refresh keeps the content on screen', () async {
    final Future<void> first = cubit.load();
    await answer();
    await first;
    final HomeState loaded = cubit.state;

    final Future<void> refresh = cubit.load();
    expect(cubit.state, loaded, reason: 'no loading flash on refresh');
    await answer(catalogFailure: const NetworkFailure());
    await refresh;

    expect(cubit.state, loaded);
  });

  test('ignores a load while one is in flight', () async {
    final Future<void> first = cubit.load();
    unawaited(cubit.load());

    expect(account.calls, hasLength(1));
    await answer();
    await first;
  });

  test('a new zone reloads the catalog for it', () async {
    final Future<void> first = cubit.load();
    await answer();
    await first;

    zone.change(<int>[7]);
    expect(account.calls, hasLength(2), reason: 'reloaded');
    await answer();
    await pumpEventQueue();

    expect((cubit.state as HomeLoaded).zoneIds, <int>[7]);
  });

  test('stops following zone changes once closed', () async {
    await cubit.close();

    zone.change(<int>[7]);

    expect(account.calls, isEmpty);
  });
}
