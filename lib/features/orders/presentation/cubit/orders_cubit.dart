import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/realtime/realtime_event.dart';
import '../../../../core/realtime/realtime_repository.dart';
import '../../../catalog/domain/entities/catalog_page.dart';
import '../../domain/entities/order_list_entry.dart';
import '../../domain/repos/orders_repository.dart';
import 'orders_state.dart';

/// Tab-scoped (provided at the orders route). Pages through the running
/// and the past orders, each list on its own — a refresh or a page of one
/// never waits on, or overwrites, the other.
class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRepository repository;

  /// With [realtime], both lists reload when the server reports an order
  /// changed (its status, or a driver taking it) — a running order moves
  /// to the past list the moment it's delivered.
  OrdersCubit({required this.repository, RealtimeRepository? realtime})
    : super(const OrdersState()) {
    _realtimeSub = realtime?.events
        .where(
          (RealtimeEvent e) =>
              e is OrderStatusChanged ||
              e is DriverAssigned ||
              e is RealtimeReconnected,
        )
        .listen((_) => load());
  }

  StreamSubscription<RealtimeEvent>? _realtimeSub;

  @override
  Future<void> close() async {
    await _realtimeSub?.cancel();
    return super.close();
  }

  /// Per list, bumped by every first-page load. An answer for an older
  /// generation — a page of the list as it was before a refresh — is
  /// dropped instead of appending stale orders to the refreshed list.
  final Map<OrdersSection, int> _generation = <OrdersSection, int>{
    for (final OrdersSection section in OrdersSection.values) section: 0,
  };

  /// Lists whose newest first-page load is still running. A page requested
  /// meanwhile would share its generation and append to the list being
  /// replaced, so [loadMoreOf] waits for it.
  final Set<OrdersSection> _firstPageInFlight = <OrdersSection>{};

  /// (Re)loads the first page of both lists. A refresh keeps each list on
  /// screen while it runs, and through a failure.
  Future<void> load() => Future.wait<void>(<Future<void>>[
    for (final OrdersSection section in OrdersSection.values)
      _loadFirstPage(section),
  ]);

  void selectFilter(OrdersFilter filter) {
    if (filter != state.filter) emit(state.withFilter(filter));
  }

  /// The end of what the filter shows was reached: pages that list. "All"
  /// shows the running orders first, so they're paged before the past ones.
  Future<void> loadMore() => loadMoreOf(switch (state.filter) {
    OrdersFilter.current => OrdersSection.running,
    OrdersFilter.past => OrdersSection.past,
    OrdersFilter.all => switch (state.running) {
      OrderListLoaded(hasMore: true) => OrdersSection.running,
      _ => OrdersSection.past,
    },
  });

  /// Fetches [section]'s next page, if any. Ignored while one — or a
  /// first-page load of that list — is in flight.
  Future<void> loadMoreOf(OrdersSection section) async {
    final OrderListState current = state.of(section);
    if (_firstPageInFlight.contains(section) ||
        current is! OrderListLoaded ||
        !current.hasMore ||
        current.loadMore is LoadMoreInProgress) {
      return;
    }
    final int generation = _generation[section]!;
    emit(
      state.withList(
        section,
        current.copyWith(loadMore: const LoadMoreInProgress()),
      ),
    );

    final int page = current.page + 1;
    final Either<Failure, CatalogPage<OrderListEntry>> result = await _fetch(
      section,
      page,
    );
    if (isClosed || generation != _generation[section]) return;

    result.fold(
      (Failure failure) => emit(
        state.withList(
          section,
          current.copyWith(loadMore: LoadMoreFailed(failure)),
        ),
      ),
      (CatalogPage<OrderListEntry> next) {
        final List<OrderListEntry> orders = <OrderListEntry>[
          ...current.orders,
          ...next.items,
        ];
        emit(
          state.withList(
            section,
            OrderListLoaded(
              orders: orders,
              totalSize: next.totalSize,
              page: page,
              hasMore: next.hasMoreAfter(orders.length),
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadFirstPage(OrdersSection section) async {
    final int generation = _generation[section] = _generation[section]! + 1;
    _firstPageInFlight.add(section);
    final bool keepVisible = state.of(section) is OrderListLoaded;
    if (!keepVisible) emit(state.withList(section, const OrderListLoading()));

    final Either<Failure, CatalogPage<OrderListEntry>> result;
    try {
      result = await _fetch(section, 1);
    } finally {
      // An older load finishing mustn't unblock paging for the newest one.
      // In `finally`, so an unexpected throw can't block paging for good.
      if (generation == _generation[section]) {
        _firstPageInFlight.remove(section);
      }
    }
    if (isClosed || generation != _generation[section]) return;

    result.fold(
      (Failure failure) {
        final OrderListState current = state.of(section);
        if (!keepVisible) {
          emit(state.withList(section, OrderListError(failure)));
        } else if (current is OrderListLoaded &&
            current.loadMore is LoadMoreInProgress) {
          // This load superseded that page request, whose answer is dropped.
          emit(
            state.withList(
              section,
              current.copyWith(loadMore: const LoadMoreIdle()),
            ),
          );
        }
      },
      (CatalogPage<OrderListEntry> page) => emit(
        state.withList(
          section,
          OrderListLoaded(
            orders: page.items,
            totalSize: page.totalSize,
            page: 1,
            hasMore: page.hasMoreAfter(page.items.length),
          ),
        ),
      ),
    );
  }

  Future<Either<Failure, CatalogPage<OrderListEntry>>> _fetch(
    OrdersSection section,
    int page,
  ) => switch (section) {
    OrdersSection.running => repository.getRunningOrders(page: page),
    OrdersSection.past => repository.getPastOrders(page: page),
  };
}
