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

  void emit(RealtimeEvent event) => _events.add(event);

  @override
  Stream<RealtimeEvent> get events => _events.stream;

  @override
  Future<void> connect() async => connectCalls++;

  @override
  Future<void> disconnect() async => disconnectCalls++;

  @override
  void watchOrder(int orderId) => watched.add(orderId);

  @override
  void unwatchOrder(int orderId) => unwatched.add(orderId);
}
