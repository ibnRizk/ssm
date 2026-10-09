import 'realtime_event.dart';

/// The customer's realtime feed (Pusher protocol): `private-customer.{id}`
/// while connected, plus `private-order.{id}` for each watched order.
///
/// Every method is safe to call while realtime is unconfigured or the
/// socket is down — the feed is an optimisation over REST, never a
/// dependency, so nothing here reports failures to callers.
abstract class RealtimeRepository {
  /// Broadcast; outdated order status versions are already filtered out.
  Stream<RealtimeEvent> get events;

  /// Opens the socket and subscribes to the signed-in customer's channel.
  /// A second call while connected does nothing.
  Future<void> connect();

  /// Closes the socket and forgets the session (customer id, watched
  /// orders, seen versions) — the next customer on this device starts clean.
  Future<void> disconnect();

  /// Also subscribes to [orderId]'s own channel. Reference-counted: two
  /// screens may watch the same order, and it stays subscribed until both
  /// call [unwatchOrder].
  void watchOrder(int orderId);

  void unwatchOrder(int orderId);
}
