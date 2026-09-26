import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../catalog/domain/entities/catalog_page.dart';
import '../../../catalog/domain/entities/store.dart';
import '../../../catalog/domain/entities/store_item.dart';
import '../../../catalog/domain/repos/catalog_repository.dart';
import 'store_details_state.dart';

/// Screen-scoped (one per store-details route). [preview] is the list entry
/// the customer tapped, so the header renders before the details arrive.
class StoreDetailsCubit extends Cubit<StoreDetailsState> {
  final CatalogRepository repository;
  final int storeId;

  StoreDetailsCubit({
    required this.repository,
    required this.storeId,
    Store? preview,
  }) : super(StoreDetailsLoading(store: preview));

  /// Bumped by every full load, so a page of items requested before a
  /// refresh isn't appended to the refreshed list.
  int _generation = 0;
  bool _loading = false;

  /// Fetches the store and its first page of items concurrently. A refresh
  /// keeps the screen visible while it runs, and through a failure.
  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    final int generation = ++_generation;
    final StoreDetailsState before = state;
    final bool refreshing = before is StoreDetailsLoaded;
    if (!refreshing) emit(StoreDetailsLoading(store: before.store));

    final (
      Either<Failure, Store> details,
      Either<Failure, CatalogPage<StoreItem>> items,
    ) = await (
      repository.getStoreDetails(storeId),
      repository.getStoreItems(storeId: storeId, page: 1),
    ).wait;

    _loading = false;
    if (isClosed || generation != _generation) return;

    void failed(Failure failure) {
      final StoreDetailsState current = state;
      if (!refreshing) {
        emit(StoreDetailsError(failure, store: before.store));
      } else if (current is StoreDetailsLoaded &&
          current.loadMore is LoadMoreInProgress) {
        // This load superseded that page request, whose answer is dropped.
        emit(current.copyWith(loadMore: const LoadMoreIdle()));
      }
    }

    details.fold(
      failed,
      (Store store) => items.fold(
        failed,
        (CatalogPage<StoreItem> page) => emit(
          StoreDetailsLoaded(
            store: store,
            items: page.items,
            page: 1,
            hasMore: page.hasMoreAfter(page.items.length),
          ),
        ),
      ),
    );
  }

  /// Fetches the next page of items, if any. Ignored while one — or a full
  /// load — is in flight: a page requested during a refresh would share its
  /// generation and append stale items to the refreshed list.
  Future<void> loadMore() async {
    final StoreDetailsState current = state;
    if (_loading ||
        current is! StoreDetailsLoaded ||
        !current.hasMore ||
        current.loadMore is LoadMoreInProgress) {
      return;
    }
    final int generation = _generation;
    emit(current.copyWith(loadMore: const LoadMoreInProgress()));

    final int page = current.page + 1;
    final Either<Failure, CatalogPage<StoreItem>> result = await repository
        .getStoreItems(storeId: storeId, page: page);
    if (isClosed || generation != _generation) return;

    result.fold(
      (Failure failure) =>
          emit(current.copyWith(loadMore: LoadMoreFailed(failure))),
      (CatalogPage<StoreItem> next) {
        final List<StoreItem> items = <StoreItem>[
          ...current.items,
          ...next.items,
        ];
        emit(
          StoreDetailsLoaded(
            store: current.store,
            items: items,
            page: page,
            hasMore: next.hasMoreAfter(items.length),
          ),
        );
      },
    );
  }
}
