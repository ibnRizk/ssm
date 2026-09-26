import 'package:ssm/core/error/failures.dart';
import 'package:ssm/features/catalog/domain/entities/store.dart';
import 'package:ssm/features/catalog/domain/entities/store_item.dart';
import 'package:ssm/features/restaurants/presentation/cubit/store_details_cubit.dart';
import 'package:ssm/features/restaurants/presentation/cubit/store_details_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_catalog_repository.dart';

List<int> _itemIds(StoreDetailsState state) =>
    (state as StoreDetailsLoaded).items.map((StoreItem i) => i.id).toList();

void main() {
  const Store preview = Store(id: 7, name: 'Mazaq');
  const Store details = Store(id: 7, name: 'Mazaq', rating: 4.8);

  late FakeCatalogRepository catalog;
  late StoreDetailsCubit cubit;

  setUp(() {
    catalog = FakeCatalogRepository();
    cubit = StoreDetailsCubit(
      repository: catalog,
      storeId: 7,
      preview: preview,
    );
  });

  tearDown(() => cubit.close());

  Future<void> loadDetails({int total = 4}) async {
    final Future<void> load = cubit.load();
    catalog.detailsCalls.last.succeed(details);
    catalog.itemCalls.last.succeed(itemsPage(<int>[1, 2], total: total));
    await load;
  }

  test('shows the tapped list entry before anything loads', () {
    expect(cubit.state, const StoreDetailsLoading(store: preview));
  });

  test('loads the details and the first page of items', () async {
    await loadDetails();

    final StoreDetailsLoaded state = cubit.state as StoreDetailsLoaded;
    expect(state.store, details);
    expect(_itemIds(state), <int>[1, 2]);
    expect(state.hasMore, isTrue);
  });

  test('a failure keeps the preview for the header', () async {
    final Future<void> load = cubit.load();
    catalog.detailsCalls.single.fail(const ServerFailure(message: 'gone'));
    catalog.itemCalls.single.succeed(itemsPage(<int>[1], total: 1));
    await load;

    expect(
      cubit.state,
      const StoreDetailsError(ServerFailure(message: 'gone'), store: preview),
    );
  });

  test('a failed items page is an error too', () async {
    final Future<void> load = cubit.load();
    catalog.detailsCalls.single.succeed(details);
    catalog.itemCalls.single.fail(const NetworkFailure());
    await load;

    expect(cubit.state, isA<StoreDetailsError>());
  });

  test('loadMore appends the next page of items', () async {
    await loadDetails();

    final Future<void> more = cubit.loadMore();
    expect(catalog.itemCalls.last.page, 2);
    catalog.itemCalls.last.succeed(itemsPage(<int>[3, 4], total: 4));
    await more;

    expect(_itemIds(cubit.state), <int>[1, 2, 3, 4]);
    expect((cubit.state as StoreDetailsLoaded).hasMore, isFalse);
  });

  test('a page requested before a refresh is not appended', () async {
    await loadDetails();
    final Future<void> more = cubit.loadMore();

    final Future<void> refresh = cubit.load();
    catalog.detailsCalls.last.succeed(details);
    catalog.itemCalls.last.succeed(itemsPage(<int>[1, 2], total: 4));
    await refresh;
    catalog.itemCalls[1].succeed(itemsPage(<int>[3, 4], total: 4));
    await more;

    expect(_itemIds(cubit.state), <int>[1, 2]);
    expect((cubit.state as StoreDetailsLoaded).loadMore, const LoadMoreIdle());
  });

  test('loadMore during a refresh is ignored, so the refresh wins', () async {
    await loadDetails();

    final Future<void> refresh = cubit.load();
    await cubit.loadMore();
    expect(catalog.itemCalls, hasLength(2), reason: 'no page 2 requested');

    catalog.detailsCalls.last.succeed(details);
    catalog.itemCalls.last.succeed(itemsPage(<int>[5, 6], total: 4));
    await refresh;

    expect(_itemIds(cubit.state), <int>[5, 6]);
  });
}
