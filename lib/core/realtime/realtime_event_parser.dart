import '../api/json_readers.dart';
import 'realtime_event.dart';

/// Builds a [RealtimeEvent] from one socket frame, or null for anything the
/// app doesn't act on (`pusher:*` internals, unknown events, an order event
/// with no order id).
///
/// Laravel Echo writes these as `.ssm.order.status_changed` — the leading
/// dot only tells Echo not to prefix the event's PHP namespace. On the wire
/// the name has no dot, so both spellings are accepted.
///
/// The guide doesn't document the event bodies, so ids are read leniently:
/// `order_id`, then `order.id`, then `id`, and finally the id in a
/// `private-order.{id}` channel name.
RealtimeEvent? parseRealtimeEvent({
  required String name,
  required String? channelName,
  required Map<String, dynamic>? data,
}) {
  final String event = name.startsWith('.') ? name.substring(1) : name;
  final Map<String, dynamic> body = data ?? const <String, dynamic>{};

  switch (event) {
    case 'ssm.order.status_changed':
      final int? orderId = _orderId(body, channelName);
      if (orderId == null) return null;
      return OrderStatusChanged(
        orderId,
        status: jsonString(body['ssm_status']) ?? jsonString(body['status']),
        statusVersion:
            jsonInt(body['status_version']) ??
            jsonInt(body['ssm_status_version']),
      );
    case 'ssm.driver.assigned':
      final int? orderId = _orderId(body, channelName);
      return orderId == null ? null : DriverAssigned(orderId);
    case 'ssm.driver.location_updated':
      final int? orderId = _orderId(body, channelName);
      return orderId == null ? null : DriverLocationUpdated(orderId);
    case 'ssm.notification.created':
      return NotificationCreated(unreadCount: jsonInt(body['unread_count']));
  }
  return null;
}

int? _orderId(Map<String, dynamic> body, String? channelName) {
  final dynamic order = body['order'];
  return jsonInt(body['order_id']) ??
      (order is Map ? jsonInt(order['id']) : null) ??
      jsonInt(body['id']) ??
      _orderIdFromChannel(channelName);
}

int? _orderIdFromChannel(String? channelName) {
  const String prefix = 'private-order.';
  if (channelName == null || !channelName.startsWith(prefix)) return null;
  return int.tryParse(channelName.substring(prefix.length));
}
