import 'dart:async';

import 'package:dart_pusher_channels/dart_pusher_channels.dart';

import '../api/api_endpoints.dart';
import '../api/dio_consumer.dart';
import '../utils/log_utils.dart';

/// Where the Pusher-protocol server lives (from `.env`, see `AppEnv`).
class RealtimeSocketConfig {
  final String scheme;
  final String host;
  final int port;

  /// Public by design — every client sends it in the socket URL.
  final String appKey;

  const RealtimeSocketConfig({
    required this.scheme,
    required this.host,
    required this.port,
    required this.appKey,
  });
}

/// One frame received on a subscribed channel.
class RealtimeSocketFrame {
  final String name;
  final String? channelName;
  final Map<String, dynamic>? data;

  const RealtimeSocketFrame({
    required this.name,
    required this.channelName,
    required this.data,
  });
}

abstract class RealtimeSocketDataSource {
  /// App events on subscribed channels; protocol internals are filtered out.
  Stream<RealtimeSocketFrame> get frames;

  /// Fires on every established connection, the first one included.
  Stream<void> get connectionEstablished;

  /// Whether a connection is established right now.
  bool get isConnected;

  Future<void> connect();

  Future<void> disconnect();

  /// Kept across reconnects until [unsubscribe]. May be called before
  /// [connect]; the subscription is made once the socket is up.
  void subscribe(String channelName);

  void unsubscribe(String channelName);
}

/// `dart_pusher_channels` (pure Dart) rather than the official plugin: the
/// official one only knows Pusher's own clusters, while this backend runs a
/// self-hosted Pusher-protocol server on its own host.
class PusherSocketDataSource implements RealtimeSocketDataSource {
  /// Null while realtime is unconfigured — every call is then a no-op.
  final RealtimeSocketConfig? config;
  final DioConsumer consumer;

  PusherSocketDataSource({required this.config, required this.consumer});

  final StreamController<RealtimeSocketFrame> _frames =
      StreamController<RealtimeSocketFrame>.broadcast();
  final StreamController<void> _established =
      StreamController<void>.broadcast();

  PusherChannelsClient? _client;
  final List<StreamSubscription<dynamic>> _clientSubs =
      <StreamSubscription<dynamic>>[];
  bool _connected = false;

  /// What the app wants subscribed, so it survives reconnects and can be
  /// requested before the socket exists.
  final Set<String> _wanted = <String>{};
  final Map<String, PrivateChannel> _channels = <String, PrivateChannel>{};
  final Map<String, StreamSubscription<ChannelReadEvent>> _channelSubs =
      <String, StreamSubscription<ChannelReadEvent>>{};

  @override
  Stream<RealtimeSocketFrame> get frames => _frames.stream;

  @override
  Stream<void> get connectionEstablished => _established.stream;

  @override
  bool get isConnected => _connected;

  @override
  Future<void> connect() async {
    final RealtimeSocketConfig? config = this.config;
    if (config == null || _client != null) return;

    final PusherChannelsClient client = PusherChannelsClient.websocket(
      options: PusherChannelsOptions.fromHost(
        scheme: config.scheme,
        host: config.host,
        port: config.port,
        key: config.appKey,
      ),
      // Keep retrying; the library spaces attempts by the delay below.
      connectionErrorHandler:
          (dynamic error, StackTrace _, void Function() refresh) {
            Log.w('[realtime] connection error: $error');
            refresh();
          },
      minimumReconnectDelayDuration: const Duration(seconds: 3),
    );
    _client = client;

    _clientSubs.add(
      client.lifecycleStream.listen((PusherChannelsClientLifeCycleState s) {
        _connected =
            s == PusherChannelsClientLifeCycleState.establishedConnection;
      }),
    );
    _clientSubs.add(
      client.onConnectionEstablished.listen((_) {
        // A new connection means a new socket id: every channel has to be
        // authorized and subscribed again.
        for (final String name in _wanted) {
          _channelFor(client, name).subscribeIfNotUnsubscribed();
        }
        _established.add(null);
      }),
    );

    try {
      await client.connect();
    } catch (error) {
      // The error handler above schedules the retry.
      Log.w('[realtime] connect failed: $error');
    }
  }

  @override
  Future<void> disconnect() async {
    final PusherChannelsClient? client = _client;
    _client = null;
    _connected = false;
    _wanted.clear();
    for (final StreamSubscription<ChannelReadEvent> sub
        in _channelSubs.values) {
      await sub.cancel();
    }
    _channelSubs.clear();
    _channels.clear();
    for (final StreamSubscription<dynamic> sub in _clientSubs) {
      await sub.cancel();
    }
    _clientSubs.clear();
    if (client == null) return;
    try {
      await client.disconnect();
    } catch (_) {
      // Closing an already-dead socket; nothing left to do.
    }
    // A disposed client can't reconnect; [connect] builds a new one.
    client.dispose();
  }

  @override
  void subscribe(String channelName) {
    if (!_wanted.add(channelName)) return;
    final PusherChannelsClient? client = _client;
    // Before the socket is up there's no socket id to authorize with; the
    // connection listener subscribes everything in [_wanted].
    if (client != null && _connected) {
      _channelFor(client, channelName).subscribe();
    }
  }

  @override
  void unsubscribe(String channelName) {
    _wanted.remove(channelName);
    _channelSubs.remove(channelName)?.cancel();
    final PrivateChannel? channel = _channels.remove(channelName);
    if (channel != null && _connected) channel.unsubscribe();
  }

  PrivateChannel _channelFor(PusherChannelsClient client, String name) {
    final PrivateChannel? existing = _channels[name];
    if (existing != null) return existing;
    final PrivateChannel channel = client.privateChannel(
      name,
      authorizationDelegate: _BearerChannelAuthorization(consumer),
    );
    _channels[name] = channel;
    _channelSubs[name] = channel.bindToAll().listen((ChannelReadEvent event) {
      // `pusher:*` / `pusher_internal:*` are protocol frames, not app events.
      if (event.name.startsWith('pusher')) return;
      _frames.add(
        RealtimeSocketFrame(
          name: event.name,
          channelName: event.channelName,
          data: event.tryGetDataAsMap(),
        ),
      );
    });
    return channel;
  }
}

/// Signs a private-channel subscription through `POST /broadcasting/auth`
/// via [DioConsumer], so it carries the customer's bearer token and shares
/// the app's error mapping — an expired token signs the customer out like
/// any other 401.
class _BearerChannelAuthorization
    implements
        EndpointAuthorizableChannelAuthorizationDelegate<
          PrivateChannelAuthorizationData
        > {
  final DioConsumer consumer;

  const _BearerChannelAuthorization(this.consumer);

  @override
  EndpointAuthFailedCallback? get onAuthFailed =>
      (dynamic error, StackTrace _) =>
          Log.w('[realtime] channel authorization failed: $error');

  @override
  Future<PrivateChannelAuthorizationData> authorizationData(
    String socketId,
    String channelName,
  ) async {
    final dynamic body = await consumer.post(
      ApiEndpoints.broadcastingAuth,
      body: <String, dynamic>{
        'socket_id': socketId,
        'channel_name': channelName,
      },
    );
    final dynamic auth = body is Map ? body['auth'] : null;
    if (auth is! String || auth.isEmpty) {
      throw const FormatException('broadcasting/auth answered without `auth`');
    }
    return PrivateChannelAuthorizationData(authKey: auth);
  }
}
