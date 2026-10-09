import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../domain/entities/notification_page.dart';
import '../models/app_notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<NotificationPage> getNotifications({
    required int page,
    required int perPage,
  });

  Future<int> getUnreadCount();

  Future<void> markRead(String id);

  Future<void> markAllRead();
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  final DioConsumer consumer;

  const NotificationsRemoteDataSourceImpl({required this.consumer});

  @override
  Future<NotificationPage> getNotifications({
    required int page,
    required int perPage,
  }) async => NotificationPageModel.fromJson(
    await consumer.get(
      ApiEndpoints.notifications,
      queryParameters: <String, dynamic>{
        'page': page,
        'per_page': perPage,
        'status': 'all',
      },
    ),
  );

  @override
  Future<int> getUnreadCount() async => unreadCountFromJson(
    await consumer.get(ApiEndpoints.notificationsUnreadCount),
  );

  @override
  Future<void> markRead(String id) =>
      consumer.patch(ApiEndpoints.notificationRead(Uri.encodeComponent(id)));

  @override
  Future<void> markAllRead() =>
      consumer.post(ApiEndpoints.notificationsReadAll);
}
