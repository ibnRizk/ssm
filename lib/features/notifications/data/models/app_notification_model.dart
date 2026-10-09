import '../../../../core/api/json_readers.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_page.dart';

/// One item of `GET /customer/notifications`:
/// `{ id, type, title, body, entity: { type, id }, is_read, read_at,
/// created_at, occurred_at }`.
class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.isRead,
    super.type,
    super.entityType,
    super.entityId,
    super.readAt,
    super.createdAt,
    super.occurredAt,
  });

  /// Null for an item without an id — it couldn't be marked read.
  static AppNotificationModel? tryFromJson(dynamic json) {
    if (json is! Map) return null;
    final String? id = json['id'] == null ? null : jsonString('${json['id']}');
    if (id == null) return null;
    final dynamic entity = json['entity'];
    final DateTime? readAt = _date(json['read_at']);
    return AppNotificationModel(
      id: id,
      type: jsonString(json['type']),
      title: jsonString(json['title']) ?? '',
      body: jsonString(json['body']) ?? '',
      entityType: entity is Map ? jsonString(entity['type']) : null,
      entityId: entity is Map && entity['id'] != null
          ? jsonString('${entity['id']}')
          : null,
      // `read_at` set means read, even if `is_read` is missing.
      isRead: jsonBool(json['is_read']) ?? readAt != null,
      readAt: readAt,
      createdAt: _date(json['created_at']),
      occurredAt: _date(json['occurred_at']),
    );
  }

  /// Server times are UTC; shown in the device's zone.
  static DateTime? _date(dynamic value) =>
      DateTime.tryParse(jsonString(value) ?? '')?.toLocal();
}

/// Laravel resource pagination: `{ data: [...], links: {...},
/// meta: { current_page, last_page, per_page, total } }`.
abstract final class NotificationPageModel {
  /// Throws [ServerException] when the body has no `data` list.
  static NotificationPage fromJson(dynamic json) {
    final dynamic data = json is Map ? json['data'] : null;
    if (data is! List) throw const ServerException();
    final dynamic meta = json['meta'];
    final List<AppNotification> items = data
        .map(AppNotificationModel.tryFromJson)
        .whereType<AppNotification>()
        .toList(growable: false);
    final int page = meta is Map ? jsonInt(meta['current_page']) ?? 1 : 1;
    return NotificationPage(
      items: items,
      page: page,
      // Without `meta`, assume this is the only page rather than paging
      // forever.
      lastPage: meta is Map ? jsonInt(meta['last_page']) ?? page : page,
      total: meta is Map
          ? jsonInt(meta['total']) ?? items.length
          : items.length,
    );
  }
}

/// `GET /customer/notifications/unread-count` → `{ count }`.
int unreadCountFromJson(dynamic json) {
  final int? count = json is Map ? jsonInt(json['count']) : null;
  if (count == null) throw const ServerException();
  return count < 0 ? 0 : count;
}
