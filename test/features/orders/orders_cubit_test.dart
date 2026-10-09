import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/features/catalog/domain/entities/catalog_page.dart';
import 'package:ssm/features/orders/domain/entities/order_list_entry.dart';
import 'package:ssm/features/orders/domain/repos/orders_repository.dart';
import 'package:ssm/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:ssm/features/orders/presentation/cubit/orders_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/realtime/realtime_event.dart';

import '../../helpers/fake_realtime_repository.dart';

typedef _Result = Either<Failure, CatalogPage<OrderListEntry>>;

/// Each request waits until the test answers it, so the order in which
/// pages come back is under the test's control.
class _FakeOrdersRepository implements OrdersRepository {
  final List<_Request> requests = <_Request>[];

  Future<_Result> _record(OrdersSection section, int page) {
    final _Request request = _Request(section, page);
    requests.add(request);
    return request.completer.future;
  }

  _Request last(OrdersSection section) =>
      requests.lastWhere((_Request r) => r.section == section);

  @override
  Future<_Result> getRunningOrders({
    required int page,
    int pageSize = ordersPageSize,
  }) => _record(OrdersSection.running, page);

  @override
  Future<_Result> getPastOrders({
    required int page,
    int pageSize = ordersPageSize,
  }) => _record(OrdersSection.past, page);

  @override
  Future<Either<Failure, List<OrderedItem>>> getOrderedItems(int orderId) =>
      throw UnimplementedError();
}

class _Request {
  final OrdersSection section;
  final int page;
  final Completer<_Result> completer = Completer<_Result>();

  _Request(this.section, this.page);

  void answer(List<int> ids, {int total = 30}) => completer.complete(
    Right<Failure, CatalogPage<OrderListEntry>>(
      CatalogPage<OrderListEntry>(
        items: <OrderListEntry>[
          for (final int id in ids)
            OrderListEntry(id: id, status: OrderListStatus.pending),
        ],
        totalSize: total,
      ),
    ),
  );

  void crash() => completer.completeError(StateError('boom'));

  void fail([Failure failure = const NetworkFailure()]) =>
      completer.complete(Left<Failure, CatalogPage<OrderListEntry>>(failure));
}

/// Lets answered requests reach the cubit before the test inspects it.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late _FakeOrdersRepository repository;
  late OrdersCubit cubit;

  setUp(() {
    repository = _FakeOrdersRepository();
    cubit = OrdersCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  OrderListLoaded loaded(OrdersSection section) =>
      cubit.state.of(section) as OrderListLoaded;

  List<int> ids(OrdersSection section) =>
      loaded(section).orders.map((OrderListEntry o) => o.id).toList();

  /// Both first pages loaded: running [1], past [101].
  Future<void> loadBoth({int runningTotal = 30, int pastTotal = 30}) async {
    final Future<void> load = cubit.load();
    repository.last(OrdersSection.running).answer(<int>[
      1,
    ], total: runningTotal);
    repository.last(OrdersSection.past).answer(<int>[101], total: pastTotal);
    await load;
  }

  test('loads the first page of both lists', () async {
    final Future<void> load = cubit.load();
    expect(cubit.state.running, const OrderListLoading());
    expect(cubit.state.past, const OrderListLoading());

    repository.last(OrdersSection.running).answer(<int>[1], total: 1);
    repository.last(OrdersSection.past).answer(<int>[101, 102], total: 11);
    await load;

    expect(ids(OrdersSection.running), <int>[1]);
    expect(loaded(OrdersSection.running).hasMore, isFalse);
    expect(ids(OrdersSection.past), <int>[101, 102]);
    expect(loaded(OrdersSection.past).hasMore, isTrue);
    expect(cubit.state.totalOrders, 12);
  });

  test('one list failing leaves the other shown', () async {
    final Future<void> load = cubit.load();
    repository.last(OrdersSection.running).fail();
    repository.last(OrdersSection.past).answer(<int>[101]);
    await load;

    expect(cubit.state.running, const OrderListError(NetworkFailure()));
    expect(ids(OrdersSection.past), <int>[101]);
    expect(cubit.state.totalOrders, isNull);
  });

  test('loadMore appends the next page of the filtered list', () async {
    await loadBoth();
    cubit.selectFilter(OrdersFilter.past);

    final Future<void> more = cubit.loadMore();
    expect(loaded(OrdersSection.past).loadMore, const LoadMoreInProgress());
    expect(repository.last(OrdersSection.past).page, 2);
    repository.last(OrdersSection.past).answer(<int>[102]);
    await more;

    expect(ids(OrdersSection.past), <int>[101, 102]);
    expect(loaded(OrdersSection.past).page, 2);
    expect(ids(OrdersSection.running), <int>[1], reason: 'untouched');
  });

  test('"All" pages the running orders first, then the past ones', () async {
    await loadBoth(runningTotal: 2);

    final Future<void> running = cubit.loadMore();
    expect(repository.requests.last.section, OrdersSection.running);
    repository.last(OrdersSection.running).answer(<int>[2], total: 2);
    await running;

    final Future<void> past = cubit.loadMore();
    expect(repository.requests.last.section, OrdersSection.past);
    repository.last(OrdersSection.past).answer(<int>[102]);
    await past;

    expect(ids(OrdersSection.running), <int>[1, 2]);
    expect(ids(OrdersSection.past), <int>[101, 102]);
  });

  test('a second loadMore while one is in flight sends nothing', () async {
    await loadBoth();
    unawaited(cubit.loadMoreOf(OrdersSection.past));
    final int sent = repository.requests.length;

    await cubit.loadMoreOf(OrdersSection.past);

    expect(repository.requests, hasLength(sent));
  });

  test('a failed page keeps the list and can be retried', () async {
    await loadBoth();
    final Future<void> more = cubit.loadMoreOf(OrdersSection.past);
    repository.last(OrdersSection.past).fail();
    await more;

    expect(
      loaded(OrdersSection.past).loadMore,
      const LoadMoreFailed(NetworkFailure()),
    );
    expect(ids(OrdersSection.past), <int>[101]);

    final Future<void> retry = cubit.loadMoreOf(OrdersSection.past);
    repository.last(OrdersSection.past).answer(<int>[102]);
    await retry;
    expect(ids(OrdersSection.past), <int>[101, 102]);
  });

  test('stops paging once every order is loaded', () async {
    await loadBoth(pastTotal: 1);
    final int sent = repository.requests.length;

    await cubit.loadMoreOf(OrdersSection.past);

    expect(repository.requests, hasLength(sent));
  });

  group('pull-to-refresh races', () {
    test('a page that lands after a refresh is dropped', () async {
      await loadBoth();
      final Future<void> more = cubit.loadMoreOf(OrdersSection.past);
      final _Request stalePage = repository.last(OrdersSection.past);

      final Future<void> refresh = cubit.load();
      repository.last(OrdersSection.running).answer(<int>[1]);
      repository.last(OrdersSection.past).answer(<int>[201]);
      await refresh;
      stalePage.answer(<int>[102]);
      await more;

      expect(ids(OrdersSection.past), <int>[201]);
      expect(loaded(OrdersSection.past).page, 1);
      expect(loaded(OrdersSection.past).loadMore, const LoadMoreIdle());
    });

    test('paging waits for a refresh in flight', () async {
      await loadBoth();
      unawaited(cubit.load());
      final int sent = repository.requests.length;

      await cubit.loadMoreOf(OrdersSection.past);

      expect(repository.requests, hasLength(sent));
    });

    test('a refresh keeps the list on screen while it runs', () async {
      await loadBoth();

      unawaited(cubit.load());

      expect(ids(OrdersSection.past), <int>[101]);
    });

    test('a failed refresh keeps the list and clears a dropped page', () async {
      await loadBoth();
      unawaited(cubit.loadMoreOf(OrdersSection.past));

      final Future<void> refresh = cubit.load();
      repository.last(OrdersSection.running).answer(<int>[1]);
      repository.last(OrdersSection.past).fail();
      await refresh;

      expect(ids(OrdersSection.past), <int>[101]);
      expect(loaded(OrdersSection.past).loadMore, const LoadMoreIdle());
    });

    test('an older refresh finishing last is dropped', () async {
      await loadBoth();
      unawaited(cubit.load());
      final _Request older = repository.last(OrdersSection.past);

      final Future<void> newer = cubit.load();
      repository.last(OrdersSection.running).answer(<int>[1]);
      repository.last(OrdersSection.past).answer(<int>[301]);
      await newer;
      older.answer(<int>[201]);
      await _settle();

      expect(ids(OrdersSection.past), <int>[301]);
    });

    test('an older refresh finishing does not unblock paging', () async {
      await loadBoth();
      unawaited(cubit.load());
      final _Request older = repository.last(OrdersSection.past);
      unawaited(cubit.load());

      older.answer(<int>[201]);
      await _settle();
      final int sent = repository.requests.length;
      await cubit.loadMoreOf(OrdersSection.past);

      expect(repository.requests, hasLength(sent));
    });
  });

  test('pages of both lists in flight together keep each other', () async {
    await loadBoth();
    final Future<void> running = cubit.loadMoreOf(OrdersSection.running);
    final Future<void> past = cubit.loadMoreOf(OrdersSection.past);

    repository.last(OrdersSection.past).answer(<int>[102]);
    await past;
    expect(loaded(OrdersSection.running).loadMore, const LoadMoreInProgress());
    repository.last(OrdersSection.running).answer(<int>[2]);
    await running;

    expect(ids(OrdersSection.running), <int>[1, 2]);
    expect(ids(OrdersSection.past), <int>[101, 102]);
  });

  test('switching filters mid-page leaves that page to land', () async {
    await loadBoth();
    cubit.selectFilter(OrdersFilter.past);
    final Future<void> more = cubit.loadMore();

    cubit.selectFilter(OrdersFilter.current);
    cubit.selectFilter(OrdersFilter.all);
    repository.last(OrdersSection.past).answer(<int>[102]);
    await more;

    expect(ids(OrdersSection.past), <int>[101, 102]);
    expect(cubit.state.filter, OrdersFilter.all);
  });

  test('a first page that throws does not block paging for good', () async {
    await loadBoth();
    final Future<void> refresh = cubit.load();
    repository.last(OrdersSection.running).answer(<int>[1]);
    repository.last(OrdersSection.past).crash();
    await expectLater(refresh, throwsStateError);
    final int sent = repository.requests.length;

    unawaited(cubit.loadMoreOf(OrdersSection.past));

    expect(repository.requests, hasLength(sent + 1));
  });

  test('selecting a filter changes only the filter', () async {
    await loadBoth();
    final OrdersState before = cubit.state;

    cubit.selectFilter(OrdersFilter.current);

    expect(cubit.state.filter, OrdersFilter.current);
    expect(cubit.state.running, before.running);
    expect(cubit.state.past, before.past);
  });

  group('realtime', () {
    late FakeRealtimeRepository realtime;

    setUp(() async {
      realtime = FakeRealtimeRepository();
      await cubit.close();
      cubit = OrdersCubit(repository: repository, realtime: realtime);
    });

    test('an order status change reloads both lists', () async {
      await loadBoth();
      final int before = repository.requests.length;

      realtime.emit(const OrderStatusChanged(1, statusVersion: 3));

      expect(repository.requests.length, before + 2);
      expect(
        repository.requests.skip(before).map((_Request r) => r.page),
        <int>[1, 1],
      );
    });

    test('a driver assignment reloads both lists', () async {
      await loadBoth();
      final int before = repository.requests.length;

      realtime.emit(const DriverAssigned(1));

      expect(repository.requests.length, before + 2);
    });

    test('driver location and notification events are ignored', () async {
      await loadBoth();
      final int before = repository.requests.length;

      realtime
        ..emit(const DriverLocationUpdated(1))
        ..emit(const NotificationCreated());

      expect(repository.requests.length, before);
    });
  });
}
