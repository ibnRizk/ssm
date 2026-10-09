import 'package:equatable/equatable.dart';

import '../../../../core/push/notification_target.dart';

class NotificationHubState extends Equatable {
  /// The inbox badge. Zero until the first count arrives.
  final int unreadCount;

  /// A tapped push the UI should open — one-shot: the listener navigates,
  /// then calls `NotificationHubCubit.targetOpened`, which clears it.
  final NotificationTarget? pendingTarget;

  const NotificationHubState({this.unreadCount = 0, this.pendingTarget});

  NotificationHubState withUnreadCount(int count) =>
      NotificationHubState(unreadCount: count, pendingTarget: pendingTarget);

  NotificationHubState withTarget(NotificationTarget? target) =>
      NotificationHubState(unreadCount: unreadCount, pendingTarget: target);

  @override
  List<Object?> get props => [unreadCount, pendingTarget];
}
