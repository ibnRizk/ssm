import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/realtime/realtime_event.dart';
import 'package:ssm/core/realtime/realtime_repository_impl.dart';
import 'package:ssm/core/realtime/realtime_socket_data_source.dart';

class _FakeSocket implements RealtimeSocketDataSource {
  final StreamController<RealtimeSocketFrame> frameController =
      StreamController<RealtimeSocketFrame>.broadcast(sync: true);
  final StreamController<void> establishedController =
      StreamController<void>.broadcast(sync: true);

  final List<String> subscribed = <String>[];
  final List<String> unsubscribed = <String>[];
  int connectCalls = 0;
  int disconnectCalls = 0;

  void frame(String name, Map<String, dynamic> data, {String? channel}) =>
      frameController.add(
        RealtimeSocketFrame(name: name, channelName: channel, data: data),
      );

  @override
  Stream<RealtimeSocketFrame> get frames => frameController.stream;

  @override
  Stream<void> get connectionEstablished => establishedController.stream;

  @override
  Future<void> connect() async => connectCalls++;

  @override
  Future<void> disconnect() async => disconnectCalls++;

  @override
  void subscribe(String channelName) => subscribed.add(channelName);

  @override
  void unsubscribe(String channelName) => unsubscribed.add(channelName);
}

void main() {
  late _FakeSocket socket;
  late RealtimeRepositoryImpl repository;
  late List<RealtimeEvent> events;
  late StreamSubscription<RealtimeEvent> sub;

  setUp(() {
    socket = _FakeSocket();
    repository = RealtimeRepositoryImpl(
      socket: socket,
      customerId: () async => 12,
    );
    events = <RealtimeEvent>[];
    sub = repository.events.listen(events.add);
  });

  tearDown(() => sub.cancel());

  test(
    "connect subscribes to the customer's channel and opens the socket",
    () async {
      await repository.connect();

      expect(socket.subscribed, <String>['private-customer.12']);
      expect(socket.connectCalls, 1);
    },
  );

  test('a second connect while connected does nothing', () async {
    await repository.connect();
    await repository.connect();

    expect(socket.connectCalls, 1);
  });

  test('without a customer id the socket stays closed', () async {
    repository = RealtimeRepositoryImpl(
      socket: socket,
      customerId: () async => null,
    );

    await repository.connect();

    expect(socket.connectCalls, 0);
    expect(socket.subscribed, isEmpty);
  });

  test('a failing customer-id lookup is swallowed', () async {
    repository = RealtimeRepositoryImpl(
      socket: socket,
      customerId: () async => throw Exception('offline'),
    );

    await expectLater(repository.connect(), completes);
    expect(socket.connectCalls, 0);
  });

  test('an order watched before connecting is subscribed on connect', () async {
    repository.watchOrder(5);
    expect(socket.subscribed, isEmpty);

    await repository.connect();

    expect(socket.subscribed, contains('private-order.5'));
  });

  test('watching is reference-counted', () async {
    await repository.connect();
    repository
      ..watchOrder(5)
      ..watchOrder(5)
      ..unwatchOrder(5);

    expect(
      socket.subscribed.where((String c) => c == 'private-order.5'),
      hasLength(1),
    );
    expect(socket.unsubscribed, isEmpty);

    repository.unwatchOrder(5);
    expect(socket.unsubscribed, <String>['private-order.5']);
  });

  test('frames become typed events', () async {
    await repository.connect();

    socket.frame('ssm.notification.created', <String, dynamic>{
      'unread_count': 2,
    });

    await pumpEventQueue();

    expect(events, <RealtimeEvent>[const NotificationCreated(unreadCount: 2)]);
  });

  test('a status already seen on another channel is dropped', () async {
    await repository.connect();
    final Map<String, dynamic> body = <String, dynamic>{
      'order_id': 5,
      'status_version': 3,
    };

    socket
      ..frame('ssm.order.status_changed', body, channel: 'private-customer.12')
      ..frame('ssm.order.status_changed', body, channel: 'private-order.5')
      ..frame('ssm.order.status_changed', <String, dynamic>{
        'order_id': 5,
        'status_version': 2,
      });

    await pumpEventQueue();

    expect(events, <RealtimeEvent>[
      const OrderStatusChanged(5, statusVersion: 3),
    ]);
  });

  test('only a re-established connection reports a reconnect', () async {
    await repository.connect();

    socket.establishedController.add(null);
    await pumpEventQueue();
    expect(events, isEmpty);

    socket.establishedController.add(null);
    await pumpEventQueue();
    expect(events, <RealtimeEvent>[const RealtimeReconnected()]);
  });

  test('disconnect closes the socket and stops events', () async {
    await repository.connect();
    await repository.disconnect();

    socket.frame('ssm.notification.created', const <String, dynamic>{});

    expect(socket.disconnectCalls, 1);
    await pumpEventQueue();
    expect(events, isEmpty);
  });

  test(
    'after disconnect, a new session starts with no seen versions',
    () async {
      final Map<String, dynamic> body = <String, dynamic>{
        'order_id': 5,
        'status_version': 3,
      };
      await repository.connect();
      socket.frame('ssm.order.status_changed', body);
      await repository.disconnect();
      await repository.connect();

      socket.frame('ssm.order.status_changed', body);

      await pumpEventQueue();

      expect(events, hasLength(2));
    },
  );

  test('a disconnect during the id lookup leaves the socket closed', () async {
    final Completer<int?> id = Completer<int?>();
    repository = RealtimeRepositoryImpl(
      socket: socket,
      customerId: () => id.future,
    );

    final Future<void> connecting = repository.connect();
    await repository.disconnect();
    id.complete(12);
    await connecting;

    expect(socket.connectCalls, 0);
  });
}
