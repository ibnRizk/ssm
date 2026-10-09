import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/features/notifications/domain/entities/app_notification.dart';
import 'package:ssm/features/notifications/domain/entities/notification_page.dart';
import 'package:ssm/features/notifications/domain/repos/notifications_repository.dart';

AppNotification notification(String id, {bool isRead = false}) =>
    AppNotification(
      id: id,
      title: 'Title $id',
      body: 'Body $id',
      isRead: isRead,
      entityType: 'order',
      entityId: '42',
    );

NotificationPage page(
  List<AppNotification> items, {
  int page = 1,
  int lastPage = 1,
}) => NotificationPage(
  items: items,
  page: page,
  lastPage: lastPage,
  total: items.length,
);

/// Each call waits on a [Completer] the test completes, so ordering and
/// overlap are explicit rather than timing-dependent.
class FakeNotificationsRepository implements NotificationsRepository {
  final List<(int, Completer<Either<Failure, NotificationPage>>)> pageCalls =
      <(int, Completer<Either<Failure, NotificationPage>>)>[];
  final List<Completer<Either<Failure, int>>> countCalls =
      <Completer<Either<Failure, int>>>[];
  final List<(String, Completer<Either<Failure, Unit>>)> markReadCalls =
      <(String, Completer<Either<Failure, Unit>>)>[];
  final List<Completer<Either<Failure, Unit>>> markAllCalls =
      <Completer<Either<Failure, Unit>>>[];

  final StreamController<void> readChanges = StreamController<void>.broadcast(
    sync: true,
  );

  void answerPage(int index, NotificationPage value) =>
      pageCalls[index].$2.complete(Right<Failure, NotificationPage>(value));

  void failPage(int index, Failure failure) =>
      pageCalls[index].$2.complete(Left<Failure, NotificationPage>(failure));

  @override
  Future<Either<Failure, NotificationPage>> getNotifications({
    required int page,
    int perPage = notificationsPageSize,
  }) {
    final Completer<Either<Failure, NotificationPage>> c =
        Completer<Either<Failure, NotificationPage>>();
    pageCalls.add((page, c));
    return c.future;
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() {
    final Completer<Either<Failure, int>> c = Completer<Either<Failure, int>>();
    countCalls.add(c);
    return c.future;
  }

  @override
  Future<Either<Failure, Unit>> markRead(String id) {
    final Completer<Either<Failure, Unit>> c =
        Completer<Either<Failure, Unit>>();
    markReadCalls.add((id, c));
    return c.future;
  }

  @override
  Future<Either<Failure, Unit>> markAllRead() {
    final Completer<Either<Failure, Unit>> c =
        Completer<Either<Failure, Unit>>();
    markAllCalls.add(c);
    return c.future;
  }

  @override
  Stream<void> get readStateChanges => readChanges.stream;
}
