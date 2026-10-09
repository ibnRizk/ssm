import 'package:equatable/equatable.dart';

import '../location/geo_point.dart';

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

/// An event about one door-to-door (customer-to-customer) parcel.
sealed class ParcelRealtimeEvent extends RealtimeEvent {
  final int parcelId;

  const ParcelRealtimeEvent(this.parcelId);

  @override
  List<Object?> get props => [parcelId];
}

/// `parcel.created`, `parcel.status_changed`, `parcel.driver_assigned`,
/// `parcel.cancelled`, `parcel.failed_delivery`, `parcel.return_started`,
/// `parcel.returned_to_sender`, `parcel.delivered` — all of them move the
/// status. Only versions newer than any already seen reach listeners.
final class ParcelStatusChanged extends ParcelRealtimeEvent {
  final String? status;
  final int? statusVersion;

  const ParcelStatusChanged(super.parcelId, {this.status, this.statusVersion});

  @override
  List<Object?> get props => [parcelId, status, statusVersion];
}

/// `parcel.driver_location_updated`, on `private-c2c-parcel.{id}.tracking`.
/// Carries the position itself, so the map can move without a refetch.
final class ParcelDriverLocationUpdated extends ParcelRealtimeEvent {
  final GeoPoint location;
  final double? heading;
  final DateTime? recordedAt;

  const ParcelDriverLocationUpdated(
    super.parcelId, {
    required this.location,
    this.heading,
    this.recordedAt,
  });

  @override
  List<Object?> get props => [parcelId, location, heading, recordedAt];
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
