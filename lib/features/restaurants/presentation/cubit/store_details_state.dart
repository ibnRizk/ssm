import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/pagination/load_more_status.dart';
import '../../../catalog/domain/entities/store.dart';
import '../../../catalog/domain/entities/store_item.dart';

export '../../../../core/pagination/load_more_status.dart';

sealed class StoreDetailsState extends Equatable {
  const StoreDetailsState();

  /// What the header can show: the full details once loaded, else the list
  /// entry the customer tapped (null when opened any other way).
  Store? get store;

  @override
  List<Object?> get props => [];
}

final class StoreDetailsLoading extends StoreDetailsState {
  @override
  final Store? store;

  const StoreDetailsLoading({this.store});

  @override
  List<Object?> get props => [store];
}

/// The store or its first page of items couldn't be fetched.
final class StoreDetailsError extends StoreDetailsState {
  final Failure failure;

  @override
  final Store? store;

  const StoreDetailsError(this.failure, {this.store});

  @override
  List<Object?> get props => [failure, store];
}

final class StoreDetailsLoaded extends StoreDetailsState {
  @override
  final Store store;
  final List<StoreItem> items;

  /// The last page of items fetched (1-based).
  final int page;
  final bool hasMore;
  final LoadMoreStatus loadMore;

  const StoreDetailsLoaded({
    required this.store,
    required this.items,
    required this.page,
    required this.hasMore,
    this.loadMore = const LoadMoreIdle(),
  });

  StoreDetailsLoaded copyWith({LoadMoreStatus? loadMore}) => StoreDetailsLoaded(
    store: store,
    items: items,
    page: page,
    hasMore: hasMore,
    loadMore: loadMore ?? this.loadMore,
  );

  @override
  List<Object?> get props => [store, items, page, hasMore, loadMore];
}
