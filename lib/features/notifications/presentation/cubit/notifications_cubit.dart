import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/pagination/load_more_status.dart';
import '../../../../core/realtime/realtime_event.dart';
import '../../../../core/realtime/realtime_repository.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_page.dart';
import '../../domain/repos/notifications_repository.dart';
import 'notifications_state.dart';

/// Screen-scoped (provided at the notifications route). Pages through the
/// inbox and refetches it when realtime says a notification arrived.
class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository repository;
  final DateTime Function() _now;

  NotificationsCubit({
    required this.repository,
    required RealtimeRepository realtime,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now,
       super(const NotificationsInitial()) {
    _realtimeSub = realtime.events
        .where(
          (RealtimeEvent e) =>
              e is NotificationCreated || e is RealtimeReconnected,
        )
        .listen((_) => refresh());
  }

  late final StreamSubscription<RealtimeEvent> _realtimeSub;

  /// Bumped by every first-page load; a page answered for an older
  /// generation is dropped instead of appended to the refreshed list.
  int _generation = 0;
  bool _firstPageInFlight = false;

  /// First load (spinner) — also the error screen's retry.
  Future<void> load() => _loadFirstPage();

  /// Pull-to-refresh and realtime: the list stays visible, and a failure
  /// leaves it as it was.
  Future<void> refresh() => _loadFirstPage();

  Future<void> loadMore() async {
    final NotificationsState current = state;
    if (_firstPageInFlight ||
        current is! NotificationsLoaded ||
        !current.hasMore ||
        current.loadMore is LoadMoreInProgress) {
      return;
    }
    final int generation = _generation;
    emit(current.copyWith(loadMore: const LoadMoreInProgress()));

    final Either<Failure, NotificationPage> result = await repository
        .getNotifications(page: current.page + 1);
    if (isClosed || generation != _generation) return;
    final NotificationsState latest = state;
    if (latest is! NotificationsLoaded) return;

    result.fold(
      (Failure failure) =>
          emit(latest.copyWith(loadMore: LoadMoreFailed(failure))),
      (NotificationPage next) {
        // A notification that arrived since page 1 shifts every later page
        // by one, so the next page can repeat the last row seen.
        final Set<String> seen = <String>{
          for (final AppNotification n in latest.items) n.id,
        };
        emit(
          latest.copyWith(
            items: <AppNotification>[
              ...latest.items,
              ...next.items.where((AppNotification n) => !seen.contains(n.id)),
            ],
            page: next.page,
            hasMore: next.hasMore,
            loadMore: const LoadMoreIdle(),
          ),
        );
      },
    );
  }

  /// Called when an unread row is tapped, before opening its target. No
  /// spinner and no error: the row turns read at once, and turns back if
  /// the server refuses.
  Future<void> markRead(AppNotification notification) async {
    if (notification.isRead) return;
    _replace(notification.id, (AppNotification n) => n.markedRead(_now()));

    final Either<Failure, Unit> result = await repository.markRead(
      notification.id,
    );
    if (isClosed || result.isRight()) return;
    _replace(notification.id, (_) => notification);
  }

  /// Optimistic like [markRead]; a failure restores the list and is
  /// reported once through [NotificationsLoaded.actionFailure].
  Future<void> markAllRead() async {
    final NotificationsState before = state;
    if (before is! NotificationsLoaded || !before.hasUnread) return;
    final DateTime at = _now();
    emit(
      before.copyWith(
        items: <AppNotification>[
          for (final AppNotification n in before.items) n.markedRead(at),
        ],
      ),
    );

    final Either<Failure, Unit> result = await repository.markAllRead();
    if (isClosed) return;
    result.fold((Failure failure) {
      final NotificationsState latest = state;
      if (latest is! NotificationsLoaded) return;
      final Map<String, AppNotification> original = <String, AppNotification>{
        for (final AppNotification n in before.items) n.id: n,
      };
      emit(
        latest.copyWith(
          items: <AppNotification>[
            for (final AppNotification n in latest.items) original[n.id] ?? n,
          ],
          actionFailure: failure,
        ),
      );
    }, (_) {});
  }

  Future<void> _loadFirstPage() async {
    final int generation = ++_generation;
    _firstPageInFlight = true;
    final bool keepVisible = state is NotificationsLoaded;
    if (!keepVisible) emit(const NotificationsLoading());

    final Either<Failure, NotificationPage> result;
    try {
      result = await repository.getNotifications(page: 1);
    } finally {
      if (generation == _generation) _firstPageInFlight = false;
    }
    if (isClosed || generation != _generation) return;

    result.fold(
      (Failure failure) {
        if (!keepVisible) emit(NotificationsError(failure));
        // Keeping the list: a page request this load superseded was
        // dropped, so its spinner must not spin forever.
        final NotificationsState current = state;
        if (current is NotificationsLoaded &&
            current.loadMore is LoadMoreInProgress) {
          emit(current.copyWith(loadMore: const LoadMoreIdle()));
        }
      },
      (NotificationPage page) => emit(
        NotificationsLoaded(
          items: page.items,
          page: page.page,
          hasMore: page.hasMore,
        ),
      ),
    );
  }

  void _replace(String id, AppNotification Function(AppNotification) update) {
    final NotificationsState current = state;
    if (current is! NotificationsLoaded) return;
    emit(
      current.copyWith(
        items: <AppNotification>[
          for (final AppNotification n in current.items)
            n.id == id ? update(n) : n,
        ],
      ),
    );
  }

  @override
  Future<void> close() async {
    await _realtimeSub.cancel();
    return super.close();
  }
}
