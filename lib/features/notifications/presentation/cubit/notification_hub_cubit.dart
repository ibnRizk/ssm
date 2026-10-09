import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/push/notification_target.dart';
import '../../../../core/push/push_payload.dart';
import '../../../../core/push/push_repository.dart';
import '../../../../core/realtime/realtime_event.dart';
import '../../../../core/realtime/realtime_repository.dart';
import '../../domain/repos/notifications_repository.dart';
import 'notification_hub_state.dart';

/// Lives as long as the signed-in shell (provided at the bottom-nav shell
/// route): mounting the shell means a customer is signed in, and leaving it
/// — logout, or a 401 bouncing to Login — ends the session.
///
/// While it lives it keeps this device registered for push, the realtime
/// socket connected, and the unread badge current; and it turns tapped
/// pushes into a [NotificationHubState.pendingTarget] for the UI to open.
class NotificationHubCubit extends Cubit<NotificationHubState> {
  final PushRepository push;
  final RealtimeRepository realtime;
  final NotificationsRepository notifications;

  NotificationHubCubit({
    required this.push,
    required this.realtime,
    required this.notifications,
  }) : super(const NotificationHubState());

  final List<StreamSubscription<dynamic>> _subs =
      <StreamSubscription<dynamic>>[];
  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    _subs
      ..add(push.taps.listen(_open))
      ..add(push.foregroundMessages.listen(_onPush))
      ..add(push.tokenRefreshes.listen((_) => push.registerDevice()))
      ..add(realtime.events.listen(_onRealtime))
      ..add(notifications.readStateChanges.listen((_) => refreshUnreadCount()));

    // Best-effort, and independent of each other: a device without push
    // still gets realtime, and neither blocks the badge.
    unawaited(push.registerDevice());
    unawaited(realtime.connect());

    final NotificationTarget? launch = await push.takeLaunchTarget();
    if (isClosed) return;
    if (launch != null) _open(launch);
    await refreshUnreadCount();
  }

  /// A failure keeps the last count — a stale badge beats a vanishing one.
  Future<void> refreshUnreadCount() async {
    final Either<Failure, int> result = await notifications.getUnreadCount();
    if (isClosed) return;
    result.fold((_) {}, (int count) => emit(state.withUnreadCount(count)));
  }

  /// The UI opened [NotificationHubState.pendingTarget].
  void targetOpened() {
    if (state.pendingTarget != null) emit(state.withTarget(null));
  }

  void _open(NotificationTarget target) {
    if (!isClosed) emit(state.withTarget(target));
  }

  void _onPush(PushPayload payload) => _applyCount(payload.unreadCount);

  void _onRealtime(RealtimeEvent event) {
    switch (event) {
      case NotificationCreated(:final int? unreadCount):
        _applyCount(unreadCount);
      case RealtimeReconnected():
        refreshUnreadCount();
      case OrderRealtimeEvent():
        break;
    }
  }

  /// The count a push or event carried, else a refetch.
  void _applyCount(int? count) {
    if (isClosed) return;
    if (count != null && count >= 0) {
      emit(state.withUnreadCount(count));
    } else {
      refreshUnreadCount();
    }
  }

  @override
  Future<void> close() async {
    for (final StreamSubscription<dynamic> sub in _subs) {
      await sub.cancel();
    }
    _subs.clear();
    // Leaving the shell ends the session — the next customer must not get
    // this one's events.
    await realtime.disconnect();
    return super.close();
  }
}
