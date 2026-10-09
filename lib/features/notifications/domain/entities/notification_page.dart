import 'package:equatable/equatable.dart';

import 'app_notification.dart';

/// One page of the inbox, newest first.
class NotificationPage extends Equatable {
  final List<AppNotification> items;

  /// 1-based.
  final int page;
  final int lastPage;
  final int total;

  const NotificationPage({
    required this.items,
    required this.page,
    required this.lastPage,
    required this.total,
  });

  bool get hasMore => page < lastPage;

  @override
  List<Object?> get props => [items, page, lastPage, total];
}
