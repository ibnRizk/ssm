import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/api/safe_api_call.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/notification_page.dart';
import '../../domain/repos/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remote;

  NotificationsRepositoryImpl({required this.remote});

  final StreamController<void> _readStateChanges =
      StreamController<void>.broadcast();

  @override
  Stream<void> get readStateChanges => _readStateChanges.stream;

  @override
  Future<Either<Failure, NotificationPage>> getNotifications({
    required int page,
    int perPage = notificationsPageSize,
  }) =>
      safeApiCall(() => remote.getNotifications(page: page, perPage: perPage));

  @override
  Future<Either<Failure, int>> getUnreadCount() =>
      safeApiCall(remote.getUnreadCount);

  @override
  Future<Either<Failure, Unit>> markRead(String id) =>
      _changingReadState(() => remote.markRead(id));

  @override
  Future<Either<Failure, Unit>> markAllRead() =>
      _changingReadState(remote.markAllRead);

  Future<Either<Failure, Unit>> _changingReadState(
    Future<void> Function() call,
  ) async {
    final Either<Failure, Unit> result = await safeApiCall(() async {
      await call();
      return unit;
    });
    if (result.isRight()) _readStateChanges.add(null);
    return result;
  }
}
