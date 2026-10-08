import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/core/location/geo_point.dart';
import 'package:ssm/core/location/location_repository.dart';
import 'package:ssm/features/catalog/domain/entities/store.dart';
import 'package:ssm/features/catalog/domain/entities/store_sort.dart';
import 'package:ssm/features/restaurants/presentation/cubit/stores_cubit.dart';
import 'package:ssm/features/restaurants/presentation/cubit/stores_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_catalog_repository.dart';
import '../../helpers/fake_zone_repository.dart';

const GeoPoint _here = GeoPoint(latitude: 30.05, longitude: 31.2);

/// Answers every location request with [answer], counting them.
class _FakeLocationRepository implements LocationRepository {
  Either<Failure, GeoPoint> answer = const Right<Failure, GeoPoint>(_here);
  int calls = 0;

  @override
  Future<Either<Failure, GeoPoint>> getCurrentLocation() async {
    calls++;
    return answer;
  }
}

List<int> _ids(StoresState state) =>
    (state as StoresLoaded).stores.map((Store s) => s.id).toList();

void main() {
  late FakeCatalogRepository catalog;
  late FakeZoneRepository zone;
  late _FakeLocationRepository location;
  late StoresCubit cubit;

  setUp(() {
    catalog = FakeCatalogRepository();
    zone = FakeZoneRepository();
    location = _FakeLocationRepository();
    cubit = StoresCubit(
      repository: catalog,
      locationRepository: location,
      zoneRepository: zone,
    );
  });

  tearDown(() => cubit.close());

  Future<void> loadFirstPage({int total = 4}) async {
    final Future<void> load = cubit.load();
    catalog.storeCalls.last.succeed(storesPage(<int>[1, 2], total: total));
    await load;
  }

  test('loads the first page of every store in the zone', () async {
    final Future<void> load = cubit.load();
    expect(cubit.state, const StoresLoading());
    expect(catalog.storeCalls.single.method, 'getStores');

    catalog.storeCalls.single.succeed(storesPage(<int>[1, 2], total: 4));
    await load;

    expect(_ids(cubit.state), <int>[1, 2]);
    expect((cubit.state as StoresLoaded).hasMore, isTrue);
    expect((cubit.state as StoresLoaded).totalSize, 4);
  });

  test('a first-page failure is an error', () async {
    final Future<void> load = cubit.load();
    catalog.storeCalls.single.fail(const NetworkFailure());
    await load;

    expect(cubit.state, const StoresError(NetworkFailure()));
  });

  test('loadMore appends the next page', () async {
    await loadFirstPage();

    final Future<void> more = cubit.loadMore();
    expect((cubit.state as StoresLoaded).loadMore, const LoadMoreInProgress());
    expect(catalog.storeCalls.last.page, 2);

    catalog.storeCalls.last.succeed(storesPage(<int>[3, 4], total: 4));
    await more;

    expect(_ids(cubit.state), <int>[1, 2, 3, 4]);
    expect((cubit.state as StoresLoaded).hasMore, isFalse);
  });

  test('loadMore is ignored once every store is loaded', () async {
    await loadFirstPage(total: 2);

    await cubit.loadMore();

    expect(catalog.storeCalls, hasLength(1));
  });

  test('a failed next page keeps the list and offers a retry', () async {
    await loadFirstPage();

    final Future<void> more = cubit.loadMore();
    catalog.storeCalls.last.fail(const NetworkFailure());
    await more;

    expect(_ids(cubit.state), <int>[1, 2]);
    expect(
      (cubit.state as StoresLoaded).loadMore,
      const LoadMoreFailed(NetworkFailure()),
    );
  });

  test('a search replaces the list with its matches', () async {
    await loadFirstPage();

    final Future<void> search = cubit.search('  burger ');
    expect(cubit.state, const StoresLoading(query: 'burger'));
    expect(catalog.storeCalls.last.method, 'searchStores');
    expect(catalog.storeCalls.last.query, 'burger');

    catalog.storeCalls.last.succeed(storesPage(<int>[9], total: 1));
    await search;

    expect(_ids(cubit.state), <int>[9]);
    expect(cubit.state.query, 'burger');
  });

  test('repeating the current search does not refetch', () async {
    await loadFirstPage();

    await cubit.search('');

    expect(catalog.storeCalls, hasLength(1));
  });

  test('an older search answering last is dropped', () async {
    final Future<void> first = cubit.search('bu');
    final Future<void> second = cubit.search('burger');

    catalog.storeCalls.last.succeed(storesPage(<int>[9], total: 1));
    await second;
    catalog.storeCalls.first.succeed(storesPage(<int>[5, 6], total: 2));
    await first;

    expect(_ids(cubit.state), <int>[9]);
    expect(cubit.state.query, 'burger');
  });

  test('a page of the previous search is not appended to a new one', () async {
    await loadFirstPage();
    final Future<void> more = cubit.loadMore();

    final Future<void> search = cubit.search('burger');
    catalog.storeCalls.last.succeed(storesPage(<int>[9], total: 1));
    await search;
    catalog.storeCalls[1].succeed(storesPage(<int>[3, 4], total: 4));
    await more;

    expect(_ids(cubit.state), <int>[9]);
  });

  test('a failed refresh during a page load clears its spinner', () async {
    await loadFirstPage();
    final Future<void> more = cubit.loadMore();

    final Future<void> refresh = cubit.load();
    catalog.storeCalls.last.fail(const NetworkFailure());
    await refresh;
    catalog.storeCalls[1].succeed(storesPage(<int>[3, 4], total: 4));
    await more;

    expect(_ids(cubit.state), <int>[1, 2]);
    expect((cubit.state as StoresLoaded).loadMore, const LoadMoreIdle());
  });

  test('loadMore during a refresh is ignored, so the refresh wins', () async {
    await loadFirstPage();

    final Future<void> refresh = cubit.load();
    await cubit.loadMore();
    expect(catalog.storeCalls, hasLength(2), reason: 'no page 2 requested');

    catalog.storeCalls.last.succeed(storesPage(<int>[7, 8], total: 4));
    await refresh;

    expect(_ids(cubit.state), <int>[7, 8]);
  });

  group('scoped to a category', () {
    late StoresCubit scoped;

    setUp(
      () => scoped = StoresCubit(
        repository: catalog,
        locationRepository: location,
        zoneRepository: zone,
        categoryId: 3,
      ),
    );

    tearDown(() => scoped.close());

    test('loads the first page of that category', () async {
      final Future<void> load = scoped.load();
      expect(catalog.storeCalls.single.method, 'getCategoryStores');
      expect(catalog.storeCalls.single.categoryId, 3);
      expect(catalog.storeCalls.single.page, 1);

      catalog.storeCalls.single.succeed(storesPage(<int>[1, 2], total: 4));
      await load;

      expect(_ids(scoped.state), <int>[1, 2]);
      expect((scoped.state as StoresLoaded).hasMore, isTrue);
    });

    test('loadMore pages through the same category', () async {
      final Future<void> load = scoped.load();
      catalog.storeCalls.last.succeed(storesPage(<int>[1, 2], total: 4));
      await load;

      final Future<void> more = scoped.loadMore();
      expect(catalog.storeCalls.last.method, 'getCategoryStores');
      expect(catalog.storeCalls.last.categoryId, 3);
      expect(catalog.storeCalls.last.page, 2);

      catalog.storeCalls.last.succeed(storesPage(<int>[3, 4], total: 4));
      await more;

      expect(_ids(scoped.state), <int>[1, 2, 3, 4]);
      expect((scoped.state as StoresLoaded).hasMore, isFalse);
    });

    test('an empty page ends the list even if the total disagrees', () async {
      final Future<void> load = scoped.load();
      catalog.storeCalls.last.succeed(storesPage(<int>[], total: 10));
      await load;

      await scoped.loadMore();

      expect((scoped.state as StoresLoaded).hasMore, isFalse);
      expect(catalog.storeCalls, hasLength(1));
    });

    test('a page answering after a refresh is not appended', () async {
      final Future<void> load = scoped.load();
      catalog.storeCalls.last.succeed(storesPage(<int>[1, 2], total: 4));
      await load;
      final Future<void> more = scoped.loadMore();

      final Future<void> refresh = scoped.load();
      catalog.storeCalls.last.succeed(storesPage(<int>[5, 6], total: 4));
      await refresh;
      catalog.storeCalls[1].succeed(storesPage(<int>[3, 4], total: 4));
      await more;

      expect(_ids(scoped.state), <int>[5, 6]);
    });
  });

  test('paging resumes once the newest first-page load answers', () async {
    await loadFirstPage();
    final Future<void> refresh = cubit.load();
    catalog.storeCalls.last.succeed(storesPage(<int>[1, 2], total: 4));
    await refresh;

    unawaited(cubit.loadMore());

    expect(catalog.storeCalls.last.page, 2);
  });

  group('sorting', () {
    /// The sorted list's first page needs no location, so it's requested
    /// synchronously; nearest-first awaits the fix before it.
    Future<void> sortFirstPage(StoreSort? sort) async {
      final Future<void> sorted = cubit.sortBy(sort);
      await pumpEventQueue();
      catalog.storeCalls.last.succeed(storesPage(<int>[5, 6], total: 4));
      await sorted;
    }

    test('a new sort reloads the first page in that order', () async {
      await loadFirstPage();

      final Future<void> sorted = cubit.sortBy(StoreSort.topRated);
      expect(cubit.state, const StoresLoading(sort: StoreSort.topRated));
      expect(catalog.storeCalls.last.method, 'getStores');
      expect(catalog.storeCalls.last.sort, StoreSort.topRated);
      expect(catalog.storeCalls.last.page, 1);
      expect(catalog.storeCalls.last.origin, isNull);

      catalog.storeCalls.last.succeed(storesPage(<int>[5, 6], total: 4));
      await sorted;

      expect(_ids(cubit.state), <int>[5, 6]);
      expect(cubit.state.sort, StoreSort.topRated);
    });

    test('loadMore pages through the same order', () async {
      await sortFirstPage(StoreSort.fastest);

      unawaited(cubit.loadMore());

      expect(catalog.storeCalls.last.sort, StoreSort.fastest);
      expect(catalog.storeCalls.last.page, 2);
    });

    test('nearest sends the customer location', () async {
      await sortFirstPage(StoreSort.nearest);

      expect(catalog.storeCalls.last.sort, StoreSort.nearest);
      expect(catalog.storeCalls.last.origin, _here);
      expect(_ids(cubit.state), <int>[5, 6]);
    });

    test('nearest pages from the same location, not a new fix', () async {
      await sortFirstPage(StoreSort.nearest);

      unawaited(cubit.loadMore());

      expect(catalog.storeCalls.last.page, 2);
      expect(catalog.storeCalls.last.origin, _here);
      expect(location.calls, 1);
    });

    test('nearest without a location is an error, not a fetch', () async {
      location.answer = const Left<Failure, GeoPoint>(
        LocationFailure(reason: LocationFailureReason.permissionDenied),
      );

      await cubit.sortBy(StoreSort.nearest);

      expect(
        cubit.state,
        const StoresError(
          LocationFailure(reason: LocationFailureReason.permissionDenied),
          sort: StoreSort.nearest,
        ),
      );
      expect(catalog.storeCalls, isEmpty);
    });

    test('the sort already shown is not refetched', () async {
      await sortFirstPage(StoreSort.topRated);

      await cubit.sortBy(StoreSort.topRated);

      expect(catalog.storeCalls, hasLength(1));
    });

    test('clearing the sort restores the default order', () async {
      await sortFirstPage(StoreSort.topRated);

      unawaited(cubit.sortBy(null));

      expect(catalog.storeCalls.last.method, 'getStores');
      expect(catalog.storeCalls.last.sort, isNull);
      expect(cubit.state, const StoresLoading());
    });

    test('an older sort answering last is dropped', () async {
      final Future<void> first = cubit.sortBy(StoreSort.topRated);
      final Future<void> second = cubit.sortBy(StoreSort.fastest);

      catalog.storeCalls.last.succeed(storesPage(<int>[9], total: 1));
      await second;
      catalog.storeCalls.first.succeed(storesPage(<int>[5, 6], total: 2));
      await first;

      expect(_ids(cubit.state), <int>[9]);
      expect(cubit.state.sort, StoreSort.fastest);
    });

    test('a search is not sorted, and keeps the sort for after it', () async {
      await sortFirstPage(StoreSort.nearest);

      final Future<void> search = cubit.search('burger');
      expect(catalog.storeCalls.last.method, 'searchStores');
      catalog.storeCalls.last.succeed(storesPage(<int>[9], total: 1));
      await search;
      expect(cubit.state.sort, StoreSort.nearest);

      final Future<void> cleared = cubit.search('');
      await pumpEventQueue();
      expect(catalog.storeCalls.last.method, 'getStores');
      expect(catalog.storeCalls.last.sort, StoreSort.nearest);
      expect(catalog.storeCalls.last.origin, _here);
      catalog.storeCalls.last.succeed(storesPage(<int>[5], total: 1));
      await cleared;
    });

    test('a category list ignores the sort', () async {
      final StoresCubit scoped = StoresCubit(
        repository: catalog,
        locationRepository: location,
        zoneRepository: zone,
        categoryId: 3,
      );
      addTearDown(scoped.close);

      unawaited(scoped.sortBy(StoreSort.nearest));

      expect(catalog.storeCalls.single.method, 'getCategoryStores');
      expect(location.calls, 0);
    });
  });

  test('a new zone reloads the list for it', () async {
    await loadFirstPage();

    zone.change(<int>[7]);
    expect(catalog.storeCalls, hasLength(2), reason: 'reloaded');
    expect(catalog.storeCalls.last.page, 1);
    catalog.storeCalls.last.succeed(storesPage(<int>[5], total: 1));
    await pumpEventQueue();

    expect(_ids(cubit.state), <int>[5]);
  });
}
