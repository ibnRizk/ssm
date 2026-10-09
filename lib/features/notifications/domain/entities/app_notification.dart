import 'package:equatable/equatable.dart';

import '../../../../core/push/notification_target.dart';

/// One inbox entry. [title] and [body] arrive already translated for the
/// `X-localization` language the request was sent in.
class AppNotification extends Equatable {
  /// Kept as a string: the guide doesn't say whether ids are numbers or
  /// UUIDs, and the app only ever sends them back in a path.
  final String id;
  final String? type;
  final String title;
  final String body;
  final String? entityType;
  final String? entityId;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;

  /// When the event itself happened — may precede [createdAt] for a
  /// notification created by a delayed job.
  final DateTime? occurredAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    this.type,
    this.entityType,
    this.entityId,
    this.readAt,
    this.createdAt,
    this.occurredAt,
  });

  NotificationTarget get target =>
      NotificationTarget.resolve(entityType: entityType, entityId: entityId);

  /// The time shown on the row.
  DateTime? get timestamp => occurredAt ?? createdAt;

  AppNotification markedRead(DateTime at) => AppNotification(
    id: id,
    type: type,
    title: title,
    body: body,
    entityType: entityType,
    entityId: entityId,
    isRead: true,
    readAt: readAt ?? at,
    createdAt: createdAt,
    occurredAt: occurredAt,
  );

  @override
  List<Object?> get props => [
    id,
    type,
    title,
    body,
    entityType,
    entityId,
    isRead,
    readAt,
    createdAt,
    occurredAt,
  ];
}
