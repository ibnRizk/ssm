import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/location/geo_point.dart';
import '../../../../core/location/location_repository.dart';
import '../../../../core/zone/zone_repository.dart';
import '../../../catalog/domain/entities/catalog_page.dart';
import '../../../catalog/domain/entities/store.dart';
import '../../../catalog/domain/entities/store_sort.dart';
import '../../../catalog/domain/repos/catalog_repository.dart';
import 'stores_state.dart';

/// A first page, and the location a nearest-first one was sorted from.
typedef _FirstPage = (Either<Failure, CatalogPage<Store>>, GeoPoint?);

/// Screen-scoped (provided at the stores route). Lists the zone's stores —
/// or one category's, when [categoryId] is set — or the ones matching a
/// search, a page at a time. The zone-wide list can be sorted.
class StoresCubit extends Cubit<StoresState> {
  final CatalogRepository repository;

  /// Where [StoreSort.nearest] measures from.
  final LocationRepository locationRepository;

  /// Scopes the unsearched list to one category. Search stays zone-wide
  /// (the API can't filter it by category), so a scoped screen hides it —
  /// and sorting, which only the zone-wide list supports.
  final int? categoryId;

  /// The stores listed belong to one zone — a new zone reloads them.
  late final StreamSubscription<List<int>> _zoneChanges;

  StoresCubit({
    required this.repository,
    required this.locationRepository,
    required ZoneRepository zoneRepository,
    this.categoryId,
  }) : super(const StoresInitial()) {
    _zoneChanges = zoneRepository.zoneChanges.listen((_) => load());
  }

  /// Bumped by every first-page load. An answer for an older generation —
  /// a search the customer has since changed, or a page of the previous
  /// results — is dropped instead of overwriting the newer list.
  int _generation = 0;

  /// Whether the newest first-page load is still running. A page requested
  /// meanwhile would share its generation and append stale stores to the
  /// refreshed list, so [loadMore] waits for it.
  bool _firstPageInFlight = false;

  /// The location the shown nearest-first list was sorted from. Its later
  /// pages reuse it, so the order can't shift as the customer moves.
  GeoPoint? _origin;

  /// (Re)loads the first page of the current search and sort. A refresh
  /// keeps the list on screen while it runs, and through a failure.
  Future<void> load() => _loadFirstPage(state.query, state.sort);

  /// Runs [query] (trimmed; empty lists every store). Ignored when it's the
  /// search already shown.
  Future<void> search(String query) {
    final String trimmed = query.trim();
    if (trimmed == state.query && state is! StoresError) {
      return Future<void>.value();
    }
    return _loadFirstPage(trimmed, state.sort);
  }

  /// Re-sorts the zone-wide list, from its first page; null restores the
  /// backend's default order. Ignored when it's the order already shown.
  Future<void> sortBy(StoreSort? sort) {
    if (sort == state.sort && state is! StoresError) {
      return Future<void>.value();
    }
    return _loadFirstPage(state.query, sort);
  }

  /// Fetches the next page, if any. Ignored while one — or a first-page
  /// load — is in flight.
  Future<void> loadMore() async {
    final StoresState current = state;
    if (_firstPageInFlight ||
        current is! StoresLoaded ||
        !current.hasMore ||
        current.loadMore is LoadMoreInProgress) {
      return;
    }
    final int generation = _generation;
    emit(current.copyWith(loadMore: const LoadMoreInProgress()));

    final int page = current.page + 1;
    final Either<Failure, CatalogPage<Store>> result = await _fetch(
      current.query,
      current.sort,
      page,
      _origin,
    );
    if (isClosed || generation != _generation) return;

    result.fold(
      (Failure failure) =>
          emit(current.copyWith(loadMore: LoadMoreFailed(failure))),
      (CatalogPage<Store> next) {
        final List<Store> stores = <Store>[...current.stores, ...next.items];
        emit(
          StoresLoaded(
            stores: stores,
            totalSize: next.totalSize,
            page: page,
            hasMore: next.hasMoreAfter(stores.length),
            query: current.query,
            sort: current.sort,
          ),
        );
      },
    );
  }

  Future<void> _loadFirstPage(String query, StoreSort? sort) async {
    final int generation = ++_generation;
    _firstPageInFlight = true;
    final StoresState before = state;
    // Keep the list during a refresh of the same search and order; a new
    // one clears it, since the old results no longer answer it.
    final bool keepVisible =
        before is StoresLoaded && before.query == query && before.sort == sort;
    if (!keepVisible) emit(StoresLoading(query: query, sort: sort));

    final (
      Either<Failure, CatalogPage<Store>> result,
      GeoPoint? origin,
    ) = await _fetchFirstPage(query, sort);
    // An older load finishing mustn't unblock paging for the newest one.
    if (generation == _generation) _firstPageInFlight = false;
    if (isClosed || generation != _generation) return;

    result.fold(
      (Failure failure) {
        final StoresState current = state;
        if (!keepVisible) {
          emit(StoresError(failure, query: query, sort: sort));
        } else if (current is StoresLoaded &&
            current.loadMore is LoadMoreInProgress) {
          // This load superseded that page request, whose answer is dropped.
          emit(current.copyWith(loadMore: const LoadMoreIdle()));
        }
      },
      (CatalogPage<Store> page) {
        _origin = origin;
        emit(
          StoresLoaded(
            stores: page.items,
            totalSize: page.totalSize,
            page: 1,
            hasMore: page.hasMoreAfter(page.items.length),
            query: query,
            sort: sort,
          ),
        );
      },
    );
  }

  /// A nearest-first list is measured from a fresh fix, so a refresh
  /// follows the customer; without one it fails like the list would.
  Future<_FirstPage> _fetchFirstPage(String query, StoreSort? sort) async {
    if (!_sorts(query) || sort != StoreSort.nearest) {
      return (await _fetch(query, sort, 1, null), null);
    }
    final Either<Failure, GeoPoint> located = await locationRepository
        .getCurrentLocation();
    return located.fold<Future<_FirstPage>>(
      (Failure failure) async =>
          (Left<Failure, CatalogPage<Store>>(failure), null),
      (GeoPoint origin) async => (await _fetch(query, sort, 1, origin), origin),
    );
  }

  /// Only the unsearched zone-wide list can be sorted.
  bool _sorts(String query) => query.isEmpty && categoryId == null;

  Future<Either<Failure, CatalogPage<Store>>> _fetch(
    String query,
    StoreSort? sort,
    int page,
    GeoPoint? origin,
  ) => switch ((query, categoryId)) {
    ('', final int categoryId) => repository.getCategoryStores(
      categoryId: categoryId,
      page: page,
    ),
    ('', null) => repository.getStores(page: page, sort: sort, origin: origin),
    _ => repository.searchStores(query: query, page: page),
  };

  @override
  Future<void> close() async {
    await _zoneChanges.cancel();
    return super.close();
  }
}
