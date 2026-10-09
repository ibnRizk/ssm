import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/core/pagination/load_more_status.dart';
import 'package:ssm/core/realtime/realtime_event.dart';
import 'package:ssm/features/notifications/domain/entities/app_notification.dart';
import 'package:ssm/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:ssm/features/notifications/presentation/cubit/notifications_state.dart';

import '../../helpers/fake_realtime_repository.dart';
import 'fake_notifications_repository.dart';

final DateTime _now = DateTime(2026, 10, 9, 12);

void main() {
  late FakeNotificationsRepository repository;
  late FakeRealtimeRepository realtime;
  late NotificationsCubit cubit;

  setUp(() {
    repository = FakeNotificationsRepository();
    realtime = FakeRealtimeRepository();
    cubit = NotificationsCubit(
      repository: repository,
      realtime: realtime,
      now: () => _now,
    );
  });

  tearDown(() => cubit.close());

  /// Loads page 1 of 2 with [items].
  Future<void> loaded(List<AppNotification> items, {int lastPage = 2}) async {
    final Future<void> load = cubit.load();
    repository.answerPage(0, page(items, lastPage: lastPage));
    await load;
  }

  NotificationsLoaded current() => cubit.state as NotificationsLoaded;

  group('load', () {
    test('shows loading, then the first page', () async {
      final Future<void> load = cubit.load();
      expect(cubit.state, const NotificationsLoading());

      repository.answerPage(0, page(<AppNotification>[notification('1')]));
      await load;

      expect(current().items.single.id, '1');
      expect(repository.pageCalls.single.$1, 1);
    });

    test('a first-load failure shows the error state', () async {
      final Future<void> load = cubit.load();
      repository.failPage(0, const NetworkFailure());
      await load;

      expect(cubit.state, const NotificationsError(NetworkFailure()));
    });
  });

  group('refresh', () {
    test('keeps the list visible while it runs', () async {
      await loaded(<AppNotification>[notification('1')]);

      final Future<void> refresh = cubit.refresh();
      expect(current().items.single.id, '1');

      repository.answerPage(1, page(<AppNotification>[notification('2')]));
      await refresh;
      expect(current().items.single.id, '2');
    });

    test('a failure keeps the list as it was', () async {
      await loaded(<AppNotification>[notification('1')]);

      final Future<void> refresh = cubit.refresh();
      repository.failPage(1, const NetworkFailure());
      await refresh;

      expect(current().items.single.id, '1');
    });

    test('a realtime notification.created triggers it', () async {
      await loaded(<AppNotification>[notification('1')]);

      realtime.emit(const NotificationCreated());

      expect(repository.pageCalls, hasLength(2));
      expect(repository.pageCalls.last.$1, 1);
    });

    test('a realtime reconnect triggers it', () async {
      await loaded(<AppNotification>[notification('1')]);

      realtime.emit(const RealtimeReconnected());

      expect(repository.pageCalls, hasLength(2));
    });

    test('order events do not', () async {
      await loaded(<AppNotification>[notification('1')]);

      realtime.emit(const DriverAssigned(42));

      expect(repository.pageCalls, hasLength(1));
    });
  });

  group('loadMore', () {
    test('appends the next page', () async {
      await loaded(<AppNotification>[notification('1')]);

      final Future<void> more = cubit.loadMore();
      expect(current().loadMore, const LoadMoreInProgress());
      repository.answerPage(
        1,
        page(<AppNotification>[notification('2')], page: 2, lastPage: 2),
      );
      await more;

      expect(current().items.map((AppNotification n) => n.id), <String>[
        '1',
        '2',
      ]);
      expect(current().hasMore, isFalse);
    });

    test('drops a row repeated because the list shifted', () async {
      await loaded(<AppNotification>[notification('1'), notification('2')]);

      final Future<void> more = cubit.loadMore();
      repository.answerPage(
        1,
        page(
          <AppNotification>[notification('2'), notification('3')],
          page: 2,
          lastPage: 2,
        ),
      );
      await more;

      expect(current().items.map((AppNotification n) => n.id), <String>[
        '1',
        '2',
        '3',
      ]);
    });

    test('does nothing on the last page', () async {
      await loaded(<AppNotification>[notification('1')], lastPage: 1);

      await cubit.loadMore();

      expect(repository.pageCalls, hasLength(1));
    });

    test('a page answered after a refresh started is dropped', () async {
      await loaded(<AppNotification>[notification('1')]);

      final Future<void> more = cubit.loadMore();
      final Future<void> refresh = cubit.refresh();
      repository.answerPage(
        1,
        page(<AppNotification>[notification('old')], page: 2, lastPage: 2),
      );
      repository.answerPage(2, page(<AppNotification>[notification('new')]));
      await Future.wait(<Future<void>>[more, refresh]);

      expect(current().items.map((AppNotification n) => n.id), <String>['new']);
    });

    test('a failure shows the retry footer', () async {
      await loaded(<AppNotification>[notification('1')]);

      final Future<void> more = cubit.loadMore();
      repository.failPage(1, const NetworkFailure());
      await more;

      expect(current().loadMore, const LoadMoreFailed(NetworkFailure()));
    });
  });

  group('markRead', () {
    test('turns the row read at once and calls the API', () async {
      await loaded(<AppNotification>[notification('1')]);

      final Future<void> mark = cubit.markRead(current().items.single);

      expect(current().items.single.isRead, isTrue);
      expect(current().items.single.readAt, _now);
      expect(repository.markReadCalls.single.$1, '1');

      repository.markReadCalls.single.$2.complete(const Right(unit));
      await mark;
      expect(current().items.single.isRead, isTrue);
    });

    test('restores the row silently when the server refuses', () async {
      await loaded(<AppNotification>[notification('1')]);

      final Future<void> mark = cubit.markRead(current().items.single);
      repository.markReadCalls.single.$2.complete(
        const Left(NotFoundFailure()),
      );
      await mark;

      expect(current().items.single.isRead, isFalse);
      expect(current().actionFailure, isNull);
    });

    test('an already-read row makes no call', () async {
      await loaded(<AppNotification>[notification('1', isRead: true)]);

      await cubit.markRead(current().items.single);

      expect(repository.markReadCalls, isEmpty);
    });
  });

  group('markAllRead', () {
    test('marks every row read optimistically', () async {
      await loaded(<AppNotification>[notification('1'), notification('2')]);

      final Future<void> mark = cubit.markAllRead();
      expect(current().hasUnread, isFalse);

      repository.markAllCalls.single.complete(const Right(unit));
      await mark;
      expect(current().hasUnread, isFalse);
    });

    test('a failure restores the rows and reports it once', () async {
      await loaded(<AppNotification>[
        notification('1'),
        notification('2', isRead: true),
      ]);

      final Future<void> mark = cubit.markAllRead();
      repository.markAllCalls.single.complete(const Left(NetworkFailure()));
      await mark;

      expect(current().items.map((AppNotification n) => n.isRead), <bool>[
        false,
        true,
      ]);
      expect(current().actionFailure, const NetworkFailure());
    });

    test('does nothing when everything is read', () async {
      await loaded(<AppNotification>[notification('1', isRead: true)]);

      await cubit.markAllRead();

      expect(repository.markAllCalls, isEmpty);
    });
  });

  test('closing stops listening to realtime', () async {
    await cubit.close();

    realtime.emit(const NotificationCreated());

    expect(repository.pageCalls, isEmpty);
  });
}
