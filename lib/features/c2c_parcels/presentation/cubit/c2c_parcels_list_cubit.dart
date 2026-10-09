import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/pagination/load_more_status.dart';
import '../../domain/entities/c2c_parcel.dart';
import '../../domain/repos/c2c_parcels_repository.dart';
import 'c2c_parcels_list_state.dart';

/// One list — the parcels the customer sends, or those sent to them —
/// paged 15 at a time. Screen-scoped, one per tab.
class C2cParcelsListCubit extends Cubit<C2cParcelsListState> {
  final C2cParcelBox box;
  final C2cParcelsRepository repository;
  final int pageSize;

  C2cParcelsListCubit({
    required this.box,
    required this.repository,
    this.pageSize = 15,
  }) : super(const C2cParcelsListLoading());

  /// Bumped by [load], so a "load more" answer for the list it replaced is
  /// dropped.
  int _generation = 0;

  /// The first page. A reload keeps the list on screen until it answers;
  /// a failed reload keeps it too.
  Future<void> load() async {
    final int generation = ++_generation;
    final C2cParcelsListState before = state;
    if (before is! C2cParcelsListLoaded) emit(const C2cParcelsListLoading());

    final Either<Failure, C2cParcelPage> result = await repository.getParcels(
      box,
      limit: pageSize,
      offset: 1,
    );
    if (isClosed || generation != _generation) return;
    result.fold(
      (Failure failure) {
        if (before is! C2cParcelsListLoaded) {
          emit(C2cParcelsListError(failure));
        }
      },
      (C2cParcelPage page) => emit(
        C2cParcelsListLoaded(
          parcels: page.parcels,
          page: 1,
          hasMore: page.hasMore,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    final C2cParcelsListState current = state;
    if (current is! C2cParcelsListLoaded ||
        !current.hasMore ||
        current.loadMore is LoadMoreInProgress) {
      return;
    }
    final int generation = _generation;
    emit(current.copyWith(loadMore: const LoadMoreInProgress()));

    final Either<Failure, C2cParcelPage> result = await repository.getParcels(
      box,
      limit: pageSize,
      offset: current.page + 1,
    );
    final C2cParcelsListState latest = state;
    if (isClosed ||
        generation != _generation ||
        latest is! C2cParcelsListLoaded) {
      return;
    }
    result.fold(
      (Failure failure) =>
          emit(latest.copyWith(loadMore: LoadMoreFailed(failure))),
      (C2cParcelPage page) {
        final Set<int> seen = latest.parcels
            .map((C2cParcelSummary p) => p.id)
            .toSet();
        emit(
          latest.copyWith(
            // A parcel created meanwhile shifts the pages by one.
            parcels: <C2cParcelSummary>[
              ...latest.parcels,
              ...page.parcels.where(
                (C2cParcelSummary p) => !seen.contains(p.id),
              ),
            ],
            page: current.page + 1,
            hasMore: page.hasMore && page.parcels.isNotEmpty,
            loadMore: const LoadMoreIdle(),
          ),
        );
      },
    );
  }
}
