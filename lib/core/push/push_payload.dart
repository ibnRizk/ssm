import 'package:equatable/equatable.dart';

import 'notification_target.dart';

/// A push as the backend sends it: **data-only and minimal** —
/// `notification_id`, `type`, `entity_type`, `entity_id`, `unread_count`.
/// It says "something happened"; the inbox and the order screens read the
/// details from REST.
///
/// FCM delivers every data value as a string, so this is parsed from a
/// `Map<String, dynamic>` of strings, leniently.
class PushPayload extends Equatable {
  final String? notificationId;
  final String? type;
  final String? entityType;
  final String? entityId;

  /// The inbox's unread count right after this push, when the server sent it.
  final int? unreadCount;

  /// Not in today's payload. Used for the banner if the backend adds them;
  /// otherwise the banner falls back to generic copy for [entityType].
  final String? title;
  final String? body;

  const PushPayload({
    this.notificationId,
    this.type,
    this.entityType,
    this.entityId,
    this.unreadCount,
    this.title,
    this.body,
  });

  factory PushPayload.fromData(Map<String, dynamic> data) => PushPayload(
    notificationId: _string(data['notification_id']),
    type: _string(data['type']),
    entityType: _string(data['entity_type']),
    entityId: _string(data['entity_id']),
    unreadCount: int.tryParse(_string(data['unread_count']) ?? ''),
    title: _string(data['title']),
    body: _string(data['body']),
  );

  /// The inverse of [PushPayload.fromData] — what travels as the local
  /// notification's payload so a tap can be routed later.
  Map<String, String> toData() => <String, String>{
    'notification_id': ?notificationId,
    'type': ?type,
    'entity_type': ?entityType,
    'entity_id': ?entityId,
    if (unreadCount case final int count) 'unread_count': '$count',
    'title': ?title,
    'body': ?body,
  };

  NotificationTarget get target =>
      NotificationTarget.resolve(entityType: entityType, entityId: entityId);

  static String? _string(dynamic value) {
    if (value == null) return null;
    final String text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  @override
  List<Object?> get props => [
    notificationId,
    type,
    entityType,
    entityId,
    unreadCount,
    title,
    body,
  ];
}
