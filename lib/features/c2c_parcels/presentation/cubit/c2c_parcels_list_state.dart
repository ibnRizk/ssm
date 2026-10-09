import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/pagination/load_more_status.dart';
import '../../domain/entities/c2c_parcel.dart';

sealed class C2cParcelsListState extends Equatable {
  const C2cParcelsListState();

  @override
  List<Object?> get props => [];
}

final class C2cParcelsListLoading extends C2cParcelsListState {
  const C2cParcelsListLoading();
}

final class C2cParcelsListError extends C2cParcelsListState {
  final Failure failure;

  const C2cParcelsListError(this.failure);

  @override
  List<Object?> get props => [failure];
}

final class C2cParcelsListLoaded extends C2cParcelsListState {
  final List<C2cParcelSummary> parcels;

  /// The last page fetched (1-based).
  final int page;
  final bool hasMore;
  final LoadMoreStatus loadMore;

  const C2cParcelsListLoaded({
    required this.parcels,
    required this.page,
    required this.hasMore,
    this.loadMore = const LoadMoreIdle(),
  });

  C2cParcelsListLoaded copyWith({
    List<C2cParcelSummary>? parcels,
    int? page,
    bool? hasMore,
    LoadMoreStatus? loadMore,
  }) => C2cParcelsListLoaded(
    parcels: parcels ?? this.parcels,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    loadMore: loadMore ?? this.loadMore,
  );

  @override
  List<Object?> get props => [parcels, page, hasMore, loadMore];
}
