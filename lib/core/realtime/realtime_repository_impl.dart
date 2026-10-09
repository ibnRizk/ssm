import 'dart:async';

import '../api/api_endpoints.dart';
import '../api/dio_consumer.dart';
import '../api/json_readers.dart';
import '../utils/log_utils.dart';
import 'realtime_event.dart';
import 'realtime_event_parser.dart';
import 'realtime_repository.dart';
import 'realtime_socket_data_source.dart';
import 'status_version_gate.dart';

/// Reads the signed-in customer's id — the `{id}` of `private-customer.{id}`.
typedef CustomerIdLookup = Future<int?> Function();

/// `GET /customer/info` → `id`. Not cached across sessions on purpose: a
/// stale id from the previous customer on this device would subscribe to a
/// channel the server refuses, and realtime would silently stay quiet.
CustomerIdLookup customerIdFromProfile(DioConsumer consumer) => () async {
  final dynamic body = await consumer.get(ApiEndpoints.customerInfo);
  return body is Map ? jsonInt(body['id']) : null;
};

class RealtimeRepositoryImpl implements RealtimeRepository {
  final RealtimeSocketDataSource socket;
  final CustomerIdLookup customerId;
  final StatusVersionGate _gate;

  RealtimeRepositoryImpl({
    required this.socket,
    required this.customerId,
    StatusVersionGate? gate,
  }) : _gate = gate ?? StatusVersionGate();

  /// Parcels and orders have separate id spaces, so separate gates.
  final StatusVersionGate _parcelGate = StatusVersionGate();

  final StreamController<RealtimeEvent> _events =
      StreamController<RealtimeEvent>.broadcast();
  StreamSubscription<RealtimeSocketFrame>? _framesSub;
  StreamSubscription<void>? _establishedSub;

  /// Watch counts per channel name — see [watchOrder].
  final Map<String, int> _watched = <String, int>{};

  String? _customerChannel;
  bool _sessionActive = false;
  bool _connecting = false;
  bool _hasConnectedOnce = false;

  /// Bumped by [disconnect], so a [connect] still awaiting the customer id
  /// doesn't open a socket for a session that already ended.
  int _session = 0;

  @override
  Stream<RealtimeEvent> get events => _events.stream;

  @override
  bool get isConnected => _sessionActive && socket.isConnected;

  @override
  Future<void> connect() async {
    if (_sessionActive || _connecting) return;
    _connecting = true;
    final int session = _session;
    try {
      final int? id = await customerId();
      if (session != _session) return;
      if (id == null) {
        Log.w('[realtime] no customer id; staying on REST only');
        return;
      }
      _sessionActive = true;
      _framesSub = socket.frames.listen(_onFrame);
      _establishedSub = socket.connectionEstablished.listen((_) {
        // The first connection is the start of the session; only a later
        // one means events may have been missed while the socket was down.
        if (_hasConnectedOnce) _events.add(const RealtimeReconnected());
        _hasConnectedOnce = true;
      });
      _customerChannel = 'private-customer.$id';
      socket.subscribe(_customerChannel!);
      _watched.keys.forEach(socket.subscribe);
      await socket.connect();
    } catch (error) {
      // Offline, or the profile call failed: realtime is best-effort.
      Log.w('[realtime] connect skipped: $error');
    } finally {
      if (session == _session) _connecting = false;
    }
  }

  @override
  Future<void> disconnect() async {
    _session++;
    _connecting = false;
    _sessionActive = false;
    _hasConnectedOnce = false;
    _customerChannel = null;
    _watched.clear();
    _gate.reset();
    _parcelGate.reset();
    await _framesSub?.cancel();
    await _establishedSub?.cancel();
    _framesSub = null;
    _establishedSub = null;
    await socket.disconnect();
  }

  @override
  void watchOrder(int orderId) => _watch(_orderChannel(orderId));

  @override
  void unwatchOrder(int orderId) => _unwatch(_orderChannel(orderId));

  @override
  void watchParcel(int parcelId) => _watch(_parcelChannel(parcelId));

  @override
  void unwatchParcel(int parcelId) => _unwatch(_parcelChannel(parcelId));

  @override
  void watchParcelTracking(int parcelId) =>
      _watch('${_parcelChannel(parcelId)}.tracking');

  @override
  void unwatchParcelTracking(int parcelId) =>
      _unwatch('${_parcelChannel(parcelId)}.tracking');

  void _watch(String channel) {
    final int count = (_watched[channel] ?? 0) + 1;
    _watched[channel] = count;
    // Before [connect] the channel is subscribed as part of connecting.
    if (count == 1 && _sessionActive) socket.subscribe(channel);
  }

  void _unwatch(String channel) {
    final int? count = _watched[channel];
    if (count == null) return;
    if (count > 1) {
      _watched[channel] = count - 1;
      return;
    }
    _watched.remove(channel);
    if (_sessionActive) socket.unsubscribe(channel);
  }

  void _onFrame(RealtimeSocketFrame frame) {
    final RealtimeEvent? event = parseRealtimeEvent(
      name: frame.name,
      channelName: frame.channelName,
      data: frame.data,
    );
    if (event == null) return;
    final bool admitted = switch (event) {
      OrderStatusChanged(:final orderId, :final statusVersion) => _gate.admit(
        orderId,
        statusVersion,
      ),
      ParcelStatusChanged(:final parcelId, :final statusVersion) =>
        _parcelGate.admit(parcelId, statusVersion),
      _ => true,
    };
    if (admitted) _events.add(event);
  }

  static String _orderChannel(int orderId) => 'private-order.$orderId';

  static String _parcelChannel(int parcelId) => 'private-c2c-parcel.$parcelId';
}
