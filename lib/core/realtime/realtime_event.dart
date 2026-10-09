import 'package:equatable/equatable.dart';

/// Something changed on the server. Realtime only signals; REST stays the
/// source of truth, so every listener reacts by refetching.
sealed class RealtimeEvent extends Equatable {
  const RealtimeEvent();

  @override
  List<Object?> get props => [];
}

/// An event about one order.
sealed class OrderRealtimeEvent extends RealtimeEvent {
  final int orderId;

  const OrderRealtimeEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

/// `.ssm.order.status_changed`. Only versions newer than any already seen
/// for the order reach listeners — see `StatusVersionGate`.
final class OrderStatusChanged extends OrderRealtimeEvent {
  /// The canonical `ssm_status`, when the event carried it.
  final String? status;
  final int? statusVersion;

  const OrderStatusChanged(super.orderId, {this.status, this.statusVersion});

  @override
  List<Object?> get props => [orderId, status, statusVersion];
}

/// `.ssm.driver.assigned`.
final class DriverAssigned extends OrderRealtimeEvent {
  const DriverAssigned(super.orderId);
}

/// `.ssm.driver.location_updated`.
final class DriverLocationUpdated extends OrderRealtimeEvent {
  const DriverLocationUpdated(super.orderId);
}

/// `.ssm.notification.created`.
final class NotificationCreated extends RealtimeEvent {
  /// The inbox's unread count after it, when the event carried it.
  final int? unreadCount;

  const NotificationCreated({this.unreadCount});

  @override
  List<Object?> get props => [unreadCount];
}

/// The socket came back after a drop. Events sent meanwhile were missed,
/// so every listener should refetch what it shows.
final class RealtimeReconnected extends RealtimeEvent {
  const RealtimeReconnected();
}
