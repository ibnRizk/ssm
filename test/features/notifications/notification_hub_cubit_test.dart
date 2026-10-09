import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/core/push/notification_target.dart';
import 'package:ssm/core/push/push_payload.dart';
import 'package:ssm/core/realtime/realtime_event.dart';
import 'package:ssm/features/notifications/presentation/cubit/notification_hub_cubit.dart';

import '../../helpers/fake_push_repository.dart';
import '../../helpers/fake_realtime_repository.dart';
import 'fake_notifications_repository.dart';

void main() {
  late FakePushRepository push;
  late FakeRealtimeRepository realtime;
  late FakeNotificationsRepository notifications;
  late NotificationHubCubit cubit;

  setUp(() {
    push = FakePushRepository();
    realtime = FakeRealtimeRepository();
    notifications = FakeNotificationsRepository();
    cubit = NotificationHubCubit(
      push: push,
      realtime: realtime,
      notifications: notifications,
    );
  });

  tearDown(() => cubit.close());

  /// Starts the hub and answers its first unread-count request.
  Future<void> started({int count = 0}) async {
    final Future<void> start = cubit.start();
    await pumpEventQueue();
    notifications.countCalls.single.complete(Right<Failure, int>(count));
    await start;
  }

  group('start', () {
    test('registers push, connects realtime and loads the count', () async {
      await started(count: 3);

      expect(push.registerCalls, 1);
      expect(realtime.connectCalls, 1);
      expect(cubit.state.unreadCount, 3);
    });

    test('a second start does nothing', () async {
      await started();
      await cubit.start();

      expect(push.registerCalls, 1);
    });

    test('replays the push that launched the app', () async {
      push.launchTarget = const OrderTarget(42);

      await started();

      expect(cubit.state.pendingTarget, const OrderTarget(42));
    });

    test('a failed count keeps the badge at its last value', () async {
      final Future<void> start = cubit.start();
      await pumpEventQueue();
      notifications.countCalls.single.complete(
        const Left<Failure, int>(NetworkFailure()),
      );
      await start;

      expect(cubit.state.unreadCount, 0);
    });
  });

  group('unread badge', () {
    test("takes a foreground push's unread_count as is", () async {
      await started(count: 1);

      push.foreground.add(const PushPayload(unreadCount: 5));

      expect(cubit.state.unreadCount, 5);
      expect(notifications.countCalls, hasLength(1));
    });

    test('refetches for a push without a count', () async {
      await started(count: 1);

      push.foreground.add(const PushPayload());

      expect(notifications.countCalls, hasLength(2));
    });

    test("takes a realtime notification's count", () async {
      await started(count: 1);

      realtime.emit(const NotificationCreated(unreadCount: 2));

      expect(cubit.state.unreadCount, 2);
    });

    test('refetches after a reconnect', () async {
      await started();

      realtime.emit(const RealtimeReconnected());

      expect(notifications.countCalls, hasLength(2));
    });

    test('refetches when the inbox marks something read', () async {
      await started(count: 4);

      notifications.readChanges.add(null);
      notifications.countCalls.last.complete(const Right<Failure, int>(3));
      await pumpEventQueue();

      expect(cubit.state.unreadCount, 3);
    });

    test('ignores order events', () async {
      await started();

      realtime.emit(const OrderStatusChanged(1, statusVersion: 2));

      expect(notifications.countCalls, hasLength(1));
    });
  });

  group('tapped pushes', () {
    test('become the pending target until opened', () async {
      await started();

      push.tapsController.add(const ParcelsTarget());
      expect(cubit.state.pendingTarget, const ParcelsTarget());

      cubit.targetOpened();
      expect(cubit.state.pendingTarget, isNull);
    });

    test('the same target tapped twice is opened twice', () async {
      await started();
      final List<NotificationTarget?> targets = <NotificationTarget?>[];
      final sub = cubit.stream.listen((s) => targets.add(s.pendingTarget));

      push.tapsController.add(const InboxTarget());
      cubit.targetOpened();
      push.tapsController.add(const InboxTarget());
      await pumpEventQueue();
      await sub.cancel();

      expect(targets.whereType<InboxTarget>(), hasLength(2));
    });
  });

  test('a rotated FCM token is registered again', () async {
    await started();

    push.refreshes.add(null);

    expect(push.registerCalls, 2);
  });

  test('closing ends the realtime session', () async {
    await started();

    await cubit.close();

    expect(realtime.disconnectCalls, 1);
  });
}
