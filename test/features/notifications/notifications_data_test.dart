import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/api/api_endpoints.dart';
import 'package:ssm/core/error/exceptions.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/core/push/notification_target.dart';
import 'package:ssm/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:ssm/features/notifications/data/models/app_notification_model.dart';
import 'package:ssm/features/notifications/data/repos/notifications_repository_impl.dart';
import 'package:ssm/features/notifications/domain/entities/app_notification.dart';
import 'package:ssm/features/notifications/domain/entities/notification_page.dart';

import '../../helpers/fake_dio_consumer.dart';

Map<String, dynamic> _item({
  Object? id = 1,
  bool isRead = false,
  String? readAt,
}) => <String, dynamic>{
  'id': id,
  'type': 'order_status_changed',
  'title': 'Order picked up',
  'body': 'Your driver is on the way.',
  'entity': <String, dynamic>{'type': 'order', 'id': 42},
  'is_read': isRead,
  'read_at': readAt,
  'created_at': '2026-10-09T10:00:00Z',
  'occurred_at': '2026-10-09T09:58:00Z',
};

void main() {
  group('AppNotificationModel', () {
    test('parses the documented item shape', () {
      final AppNotification n = AppNotificationModel.tryFromJson(_item())!;

      expect(n.id, '1');
      expect(n.title, 'Order picked up');
      expect(n.isRead, isFalse);
      expect(n.target, const OrderTarget(42));
      expect(n.timestamp, DateTime.utc(2026, 10, 9, 9, 58).toLocal());
    });

    test('accepts string (UUID) ids', () {
      expect(
        AppNotificationModel.tryFromJson(_item(id: 'b3f1-uuid'))!.id,
        'b3f1-uuid',
      );
    });

    test('an item without an id is skipped', () {
      expect(AppNotificationModel.tryFromJson(_item(id: null)), isNull);
    });

    test('a read_at without is_read still reads as read', () {
      final Map<String, dynamic> json = _item(readAt: '2026-10-09T11:00:00Z')
        ..remove('is_read');

      expect(AppNotificationModel.tryFromJson(json)!.isRead, isTrue);
    });
  });

  group('NotificationPageModel', () {
    test('reads the Laravel resource meta', () {
      final NotificationPage page = NotificationPageModel.fromJson(
        <String, dynamic>{
          'data': <dynamic>[_item(), _item(id: 2), 'garbage'],
          'links': <String, dynamic>{},
          'meta': <String, dynamic>{
            'current_page': 1,
            'last_page': 3,
            'total': 41,
          },
        },
      );

      expect(page.items, hasLength(2));
      expect(page.hasMore, isTrue);
      expect(page.total, 41);
    });

    test('without meta, the page is taken as the last one', () {
      final NotificationPage page = NotificationPageModel.fromJson(
        <String, dynamic>{
          'data': <dynamic>[_item()],
        },
      );

      expect(page.hasMore, isFalse);
    });

    test('a body without a data list is a server error', () {
      expect(
        () => NotificationPageModel.fromJson(<String, dynamic>{}),
        throwsA(isA<ServerException>()),
      );
    });
  });

  test('unread count reads `count`, never below zero', () {
    expect(unreadCountFromJson(<String, dynamic>{'count': '4'}), 4);
    expect(unreadCountFromJson(<String, dynamic>{'count': -1}), 0);
    expect(
      () => unreadCountFromJson(<String, dynamic>{}),
      throwsA(isA<ServerException>()),
    );
  });

  group('NotificationsRemoteDataSource', () {
    late FakeDioConsumer consumer;
    late NotificationsRemoteDataSource source;

    setUp(() {
      consumer = FakeDioConsumer();
      source = NotificationsRemoteDataSourceImpl(consumer: consumer);
    });

    test('lists with page, per_page and status=all', () async {
      consumer.response = <String, dynamic>{'data': <dynamic>[]};

      await source.getNotifications(page: 2, perPage: 20);

      expect(consumer.lastPath, ApiEndpoints.notifications);
      expect(consumer.lastQuery, <String, dynamic>{
        'page': 2,
        'per_page': 20,
        'status': 'all',
      });
    });

    test('marks one read with a PATCH on its id', () async {
      await source.markRead('15');

      expect(consumer.lastVerb, 'PATCH');
      expect(consumer.lastPath, '${ApiEndpoints.notifications}/15/read');
    });

    test('marks all read with a POST', () async {
      await source.markAllRead();

      expect(consumer.lastVerb, 'POST');
      expect(consumer.lastPath, ApiEndpoints.notificationsReadAll);
    });
  });

  group('NotificationsRepositoryImpl', () {
    late FakeDioConsumer consumer;
    late NotificationsRepositoryImpl repository;
    late int changes;

    setUp(() {
      consumer = FakeDioConsumer(response: <String, dynamic>{});
      repository = NotificationsRepositoryImpl(
        remote: NotificationsRemoteDataSourceImpl(consumer: consumer),
      );
      changes = 0;
      repository.readStateChanges.listen((_) => changes++);
    });

    test('a successful markRead announces a read-state change', () async {
      await repository.markRead('1');
      await pumpEventQueue();

      expect(changes, 1);
    });

    test(
      'a failed markRead announces nothing and returns the failure',
      () async {
        consumer.error = const NotFoundException();

        final Either<Failure, Unit> result = await repository.markRead('1');
        await pumpEventQueue();

        expect(result.isLeft(), isTrue);
        expect(changes, 0);
      },
    );
  });
}
