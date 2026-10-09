import 'realtime_event.dart';

/// The customer's realtime feed (Pusher protocol): `private-customer.{id}`
/// while connected, plus `private-order.{id}` for each watched order and
/// `private-c2c-parcel.{id}` (and its `.tracking` channel) for each watched
/// door-to-door parcel.
///
/// Every method is safe to call while realtime is unconfigured or the
/// socket is down — the feed is an optimisation over REST, never a
/// dependency, so nothing here reports failures to callers.
abstract class RealtimeRepository {
  /// Broadcast; outdated order and parcel status versions are already
  /// filtered out.
  Stream<RealtimeEvent> get events;

  /// Whether the socket is up right now. Screens that also poll use it to
  /// poll only while realtime can't reach them.
  bool get isConnected;

  /// Opens the socket and subscribes to the signed-in customer's channel.
  /// A second call while connected does nothing.
  Future<void> connect();

  /// Closes the socket and forgets the session (customer id, watched
  /// orders and parcels, seen versions) — the next customer on this device
  /// starts clean.
  Future<void> disconnect();

  /// Also subscribes to [orderId]'s own channel. Reference-counted: two
  /// screens may watch the same order, and it stays subscribed until both
  /// call [unwatchOrder].
  void watchOrder(int orderId);

  void unwatchOrder(int orderId);

  /// `private-c2c-parcel.{id}` — the parcel's status events. Reference-
  /// counted like [watchOrder].
  void watchParcel(int parcelId);

  void unwatchParcel(int parcelId);

  /// `private-c2c-parcel.{id}.tracking` — the driver's live position. The
  /// server only authorizes it during the stages a viewer may see the
  /// driver, so watch it from then on; watching again after an
  /// [unwatchParcelTracking] asks for a fresh authorization.
  void watchParcelTracking(int parcelId);

  void unwatchParcelTracking(int parcelId);
}
