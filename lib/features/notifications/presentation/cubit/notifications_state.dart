import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/pagination/load_more_status.dart';
import '../../domain/entities/app_notification.dart';

sealed class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

final class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

final class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

/// The first page failed; nothing to show.
final class NotificationsError extends NotificationsState {
  final Failure failure;

  const NotificationsError(this.failure);

  @override
  List<Object?> get props => [failure];
}

final class NotificationsLoaded extends NotificationsState {
  final List<AppNotification> items;

  /// The last page loaded, 1-based.
  final int page;
  final bool hasMore;
  final LoadMoreStatus loadMore;

  /// "Mark all as read" failed — one-shot, for a snack bar. Every
  /// [copyWith] clears it unless passed again.
  final Failure? actionFailure;

  const NotificationsLoaded({
    required this.items,
    required this.page,
    required this.hasMore,
    this.loadMore = const LoadMoreIdle(),
    this.actionFailure,
  });

  bool get hasUnread => items.any((AppNotification n) => !n.isRead);

  NotificationsLoaded copyWith({
    List<AppNotification>? items,
    int? page,
    bool? hasMore,
    LoadMoreStatus? loadMore,
    Failure? actionFailure,
  }) => NotificationsLoaded(
    items: items ?? this.items,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    loadMore: loadMore ?? this.loadMore,
    actionFailure: actionFailure,
  );

  @override
  List<Object?> get props => [items, page, hasMore, loadMore, actionFailure];
}
