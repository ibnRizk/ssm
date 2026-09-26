import 'dart:async';

import 'package:flutter_base/core/error/failures.dart';
import 'package:flutter_base/features/catalog/domain/entities/store.dart';
import 'package:flutter_base/features/restaurants/presentation/cubit/stores_cubit.dart';
import 'package:flutter_base/features/restaurants/presentation/cubit/stores_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_catalog_repository.dart';

List<int> _ids(StoresState state) =>
    (state as StoresLoaded).stores.map((Store s) => s.id).toList();

void main() {
  late FakeCatalogRepository catalog;
  late StoresCubit cubit;

  setUp(() {
    catalog = FakeCatalogRepository();
    cubit = StoresCubit(repository: catalog);
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

  test('paging resumes once the newest first-page load answers', () async {
    await loadFirstPage();
    final Future<void> refresh = cubit.load();
    catalog.storeCalls.last.succeed(storesPage(<int>[1, 2], total: 4));
    await refresh;

    unawaited(cubit.loadMore());

    expect(catalog.storeCalls.last.page, 2);
  });
}
