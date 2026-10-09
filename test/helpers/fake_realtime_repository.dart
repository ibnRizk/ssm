import 'dart:async';

import 'package:ssm/core/realtime/realtime_event.dart';
import 'package:ssm/core/realtime/realtime_repository.dart';

/// Events are pushed by the test with [emit]; calls are recorded.
class FakeRealtimeRepository implements RealtimeRepository {
  final StreamController<RealtimeEvent> _events =
      StreamController<RealtimeEvent>.broadcast(sync: true);

  int connectCalls = 0;
  int disconnectCalls = 0;
  final List<int> watched = <int>[];
  final List<int> unwatched = <int>[];
  final List<int> watchedParcels = <int>[];
  final List<int> unwatchedParcels = <int>[];
  final List<int> watchedParcelTracking = <int>[];
  final List<int> unwatchedParcelTracking = <int>[];

  /// What [isConnected] answers; set by the test.
  bool connected = false;

  void emit(RealtimeEvent event) => _events.add(event);

  @override
  Stream<RealtimeEvent> get events => _events.stream;

  @override
  bool get isConnected => connected;

  @override
  void watchParcel(int parcelId) => watchedParcels.add(parcelId);

  @override
  void unwatchParcel(int parcelId) => unwatchedParcels.add(parcelId);

  @override
  void watchParcelTracking(int parcelId) => watchedParcelTracking.add(parcelId);

  @override
  void unwatchParcelTracking(int parcelId) =>
      unwatchedParcelTracking.add(parcelId);

  @override
  Future<void> connect() async => connectCalls++;

  @override
  Future<void> disconnect() async => disconnectCalls++;

  @override
  void watchOrder(int orderId) => watched.add(orderId);

  @override
  void unwatchOrder(int orderId) => unwatched.add(orderId);
}
