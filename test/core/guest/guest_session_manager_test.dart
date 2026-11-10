import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/error/exceptions.dart';
import 'package:ssm/core/guest/guest_session.dart';
import 'package:ssm/core/guest/guest_session_local_data_source.dart';
import 'package:ssm/core/guest/guest_session_manager.dart';
import 'package:ssm/core/guest/guest_session_remote_data_source.dart';

class _FakeRemote implements GuestSessionRemoteDataSource {
  final List<GuestSession> answers;
  Object? error;
  int calls = 0;
  String? lastFcmToken;

  /// When set, requests wait for it — to hold several callers in flight.
  Completer<void>? gate;

  _FakeRemote(this.answers);

  @override
  Future<GuestSession> request({String? fcmToken}) async {
    calls++;
    lastFcmToken = fcmToken;
    await gate?.future;
    if (error case final Object e) throw e;
    return answers[calls - 1];
  }
}

class _FakeLocal implements GuestSessionLocalDataSource {
  GuestSession? stored;
  bool failWrites = false;

  @override
  Future<GuestSession?> read() async => stored;

  @override
  Future<void> write(GuestSession session) async {
    if (failWrites) throw Exception('keystore unavailable');
    stored = session;
  }

  @override
  Future<void> delete() async => stored = null;
}

final DateTime _now = DateTime.utc(2026, 11, 10, 12);

GuestSession _session(int id, {DateTime? expiresAt}) =>
    GuestSession(guestId: id, token: 'token-$id', expiresAt: expiresAt);

void main() {
  late _FakeRemote remote;
  late _FakeLocal local;
  late GuestSessionManager manager;
  String? fcm;

  GuestSessionManager build({Future<String?> Function()? fcmToken}) =>
      GuestSessionManagerImpl(
        remote: remote,
        local: local,
        fcmToken: fcmToken ?? () async => fcm,
        clock: () => _now,
      );

  setUp(() {
    fcm = 'fcm-abc';
    remote = _FakeRemote(<GuestSession>[_session(1), _session(2)]);
    local = _FakeLocal();
    manager = build();
  });

  group('ensure', () {
    test(
      'returns the stored session while usable, without a request',
      () async {
        local.stored = _session(
          5,
          expiresAt: _now.add(const Duration(days: 1)),
        );

        expect(await manager.ensure(), local.stored);
        expect(remote.calls, 0);
      },
    );

    test('requests and stores a session when none is stored', () async {
      final GuestSession session = await manager.ensure();

      expect(session, _session(1));
      expect(local.stored, _session(1));
    });

    test('replaces an expired session', () async {
      local.stored = _session(
        5,
        expiresAt: _now.subtract(const Duration(days: 1)),
      );

      expect(await manager.ensure(), _session(1));
    });

    test('sends the FCM token with the request', () async {
      await manager.ensure();

      expect(remote.lastFcmToken, 'fcm-abc');
    });

    test('still starts a session when the FCM token is unavailable', () async {
      manager = build(fcmToken: () async => throw Exception('no APNs token'));

      expect(await manager.ensure(), _session(1));
      expect(remote.lastFcmToken, isNull);
    });

    test('concurrent callers share one backend request', () async {
      remote.gate = Completer<void>();

      final Future<List<GuestSession>> both = Future.wait(
        <Future<GuestSession>>[manager.ensure(), manager.ensure()],
      );
      // Let both reach the in-flight request before it answers.
      await Future<void>.delayed(Duration.zero);
      remote.gate!.complete();

      expect(await both, <GuestSession>[_session(1), _session(1)]);
      expect(remote.calls, 1);
    });

    test('propagates a backend failure', () async {
      remote.error = const InternetConnectionException();

      expect(manager.ensure(), throwsA(isA<InternetConnectionException>()));
    });

    test('a session that cannot be stored is still returned', () async {
      local.failWrites = true;

      expect(await manager.ensure(), _session(1));
    });
  });

  group('renew', () {
    test('replaces the rejected session', () async {
      local.stored = _session(5);

      expect(await manager.renew(_session(5)), _session(1));
      expect(local.stored, _session(1));
    });

    test('reuses a session another request already renewed', () async {
      local.stored = _session(6);

      expect(await manager.renew(_session(5)), _session(6));
      expect(remote.calls, 0);
    });
  });

  test('storedGuestId reads the stored id, expired or not', () async {
    local.stored = _session(
      5,
      expiresAt: _now.subtract(const Duration(days: 1)),
    );

    expect(await manager.storedGuestId(), 5);
  });

  test('storedGuestId is null when the device never was a guest', () async {
    expect(await manager.storedGuestId(), isNull);
  });

  test('clear drops the stored session', () async {
    local.stored = _session(5);

    await manager.clear();

    expect(local.stored, isNull);
  });
}
