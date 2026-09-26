import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../catalog/domain/entities/catalog_page.dart';
import '../../../catalog/domain/entities/store.dart';
import '../../../catalog/domain/repos/catalog_repository.dart';
import 'stores_state.dart';

/// Screen-scoped (provided at the stores route). Lists the zone's stores —
/// or one category's, when [categoryId] is set — or the ones matching a
/// search, a page at a time.
class StoresCubit extends Cubit<StoresState> {
  final CatalogRepository repository;

  /// Scopes the unsearched list to one category. Search stays zone-wide
  /// (the API can't filter it by category), so a scoped screen hides it.
  final int? categoryId;

  StoresCubit({required this.repository, this.categoryId})
    : super(const StoresInitial());

  /// Bumped by every first-page load. An answer for an older generation —
  /// a search the customer has since changed, or a page of the previous
  /// results — is dropped instead of overwriting the newer list.
  int _generation = 0;

  /// Whether the newest first-page load is still running. A page requested
  /// meanwhile would share its generation and append stale stores to the
  /// refreshed list, so [loadMore] waits for it.
  bool _firstPageInFlight = false;

  /// (Re)loads the first page of the current search. A refresh keeps the
  /// list on screen while it runs, and through a failure.
  Future<void> load() => _loadFirstPage(state.query);

  /// Runs [query] (trimmed; empty lists every store). Ignored when it's the
  /// search already shown.
  Future<void> search(String query) {
    final String trimmed = query.trim();
    if (trimmed == state.query && state is! StoresError) {
      return Future<void>.value();
    }
    return _loadFirstPage(trimmed);
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
      page,
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
          ),
        );
      },
    );
  }

  Future<void> _loadFirstPage(String query) async {
    final int generation = ++_generation;
    _firstPageInFlight = true;
    final StoresState before = state;
    // Keep the list during a refresh of the same search; a new search
    // clears it, since the old results no longer answer it.
    final bool keepVisible = before is StoresLoaded && before.query == query;
    if (!keepVisible) emit(StoresLoading(query: query));

    final Either<Failure, CatalogPage<Store>> result = await _fetch(query, 1);
    // An older load finishing mustn't unblock paging for the newest one.
    if (generation == _generation) _firstPageInFlight = false;
    if (isClosed || generation != _generation) return;

    result.fold(
      (Failure failure) {
        final StoresState current = state;
        if (!keepVisible) {
          emit(StoresError(failure, query: query));
        } else if (current is StoresLoaded &&
            current.loadMore is LoadMoreInProgress) {
          // This load superseded that page request, whose answer is dropped.
          emit(current.copyWith(loadMore: const LoadMoreIdle()));
        }
      },
      (CatalogPage<Store> page) => emit(
        StoresLoaded(
          stores: page.items,
          totalSize: page.totalSize,
          page: 1,
          hasMore: page.hasMoreAfter(page.items.length),
          query: query,
        ),
      ),
    );
  }

  Future<Either<Failure, CatalogPage<Store>>> _fetch(String query, int page) =>
      switch ((query, categoryId)) {
        ('', final int categoryId) => repository.getCategoryStores(
          categoryId: categoryId,
          page: page,
        ),
        ('', null) => repository.getStores(page: page),
        _ => repository.searchStores(query: query, page: page),
      };
}
