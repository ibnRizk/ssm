import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/notification_page.dart';

/// The server accepts 1-50.
const int notificationsPageSize = 20;

abstract class NotificationsRepository {
  Future<Either<Failure, NotificationPage>> getNotifications({
    required int page,
    int perPage = notificationsPageSize,
  });

  Future<Either<Failure, int>> getUnreadCount();

  /// Marking one that isn't the customer's answers [NotFoundFailure].
  Future<Either<Failure, Unit>> markRead(String id);

  Future<Either<Failure, Unit>> markAllRead();

  /// Fires after [markRead] or [markAllRead] succeeds, so whatever shows
  /// the unread count can refresh it without the inbox screen telling it.
  Stream<void> get readStateChanges;
}
