import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/pagination/load_more_status.dart';
import '../../../catalog/domain/entities/store.dart';
import '../../../catalog/domain/entities/store_sort.dart';

export '../../../../core/pagination/load_more_status.dart';

sealed class StoresState extends Equatable {
  /// The search the state is for; empty lists every store of the zone.
  final String query;

  /// The order the unsearched zone-wide list is in; null for the backend's
  /// default. Kept through a search so clearing it restores the sort.
  final StoreSort? sort;

  const StoresState({this.query = '', this.sort});

  @override
  List<Object?> get props => [query, sort];
}

final class StoresInitial extends StoresState {
  const StoresInitial();
}

final class StoresLoading extends StoresState {
  const StoresLoading({super.query, super.sort});
}

/// The first page couldn't be fetched — or, for [StoreSort.nearest], the
/// customer's location couldn't be.
final class StoresError extends StoresState {
  final Failure failure;

  const StoresError(this.failure, {super.query, super.sort});

  @override
  List<Object?> get props => [failure, query, sort];
}

final class StoresLoaded extends StoresState {
  final List<Store> stores;

  /// Across every page, for the header's count.
  final int totalSize;

  /// The last page fetched (1-based).
  final int page;
  final bool hasMore;
  final LoadMoreStatus loadMore;

  const StoresLoaded({
    required this.stores,
    required this.totalSize,
    required this.page,
    required this.hasMore,
    this.loadMore = const LoadMoreIdle(),
    super.query,
    super.sort,
  });

  StoresLoaded copyWith({LoadMoreStatus? loadMore}) => StoresLoaded(
    stores: stores,
    totalSize: totalSize,
    page: page,
    hasMore: hasMore,
    loadMore: loadMore ?? this.loadMore,
    query: query,
    sort: sort,
  );

  @override
  List<Object?> get props => [
    stores,
    totalSize,
    page,
    hasMore,
    loadMore,
    query,
    sort,
  ];
}
