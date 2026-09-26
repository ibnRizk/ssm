import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/pagination/load_more_status.dart';
import '../../domain/entities/order_list_entry.dart';

export '../../../../core/pagination/load_more_status.dart';

/// The tab's filter row.
enum OrdersFilter { all, current, past }

/// The two lists the tab pages through independently.
enum OrdersSection { running, past }

sealed class OrderListState extends Equatable {
  const OrderListState();

  @override
  List<Object?> get props => [];
}

final class OrderListLoading extends OrderListState {
  const OrderListLoading();
}

/// The first page couldn't be fetched.
final class OrderListError extends OrderListState {
  final Failure failure;

  const OrderListError(this.failure);

  @override
  List<Object?> get props => [failure];
}

final class OrderListLoaded extends OrderListState {
  final List<OrderListEntry> orders;

  /// Across every page.
  final int totalSize;

  /// The last page fetched (1-based).
  final int page;
  final bool hasMore;
  final LoadMoreStatus loadMore;

  const OrderListLoaded({
    required this.orders,
    required this.totalSize,
    required this.page,
    required this.hasMore,
    this.loadMore = const LoadMoreIdle(),
  });

  OrderListLoaded copyWith({LoadMoreStatus? loadMore}) => OrderListLoaded(
    orders: orders,
    totalSize: totalSize,
    page: page,
    hasMore: hasMore,
    loadMore: loadMore ?? this.loadMore,
  );

  @override
  List<Object?> get props => [orders, totalSize, page, hasMore, loadMore];
}

class OrdersState extends Equatable {
  final OrdersFilter filter;
  final OrderListState running;
  final OrderListState past;

  const OrdersState({
    this.filter = OrdersFilter.all,
    this.running = const OrderListLoading(),
    this.past = const OrderListLoading(),
  });

  OrderListState of(OrdersSection section) => switch (section) {
    OrdersSection.running => running,
    OrdersSection.past => past,
  };

  OrdersState withList(OrdersSection section, OrderListState list) =>
      OrdersState(
        filter: filter,
        running: section == OrdersSection.running ? list : running,
        past: section == OrdersSection.past ? list : past,
      );

  OrdersState withFilter(OrdersFilter filter) =>
      OrdersState(filter: filter, running: running, past: past);

  /// For the header — null until both lists have loaded.
  int? get totalOrders => switch ((running, past)) {
    (final OrderListLoaded r, final OrderListLoaded p) =>
      r.totalSize + p.totalSize,
    _ => null,
  };

  @override
  List<Object?> get props => [filter, running, past];
}
