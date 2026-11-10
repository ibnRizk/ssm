import 'dart:async';

import 'guest_session.dart';
import 'guest_session_local_data_source.dart';
import 'guest_session_remote_data_source.dart';

/// Owns the guest session for the networking layer and the login hand-off.
///
/// Infrastructure, not a feature repository: its callers are the guest
/// interceptor and `AuthRepositoryImpl`, which need exceptions to propagate
/// through Dio — so failures throw instead of returning `Either`.
abstract class GuestSessionManager {
  /// The stored session while usable; otherwise a new one from the backend.
  /// Concurrent callers share one backend request.
  Future<GuestSession> ensure();

  /// The backend refused [rejected]. Returns a newer stored session if
  /// another request already replaced it, otherwise requests a new one.
  Future<GuestSession> renew(GuestSession? rejected);

  /// The stored guest id, expired or not — sent with login/register so the
  /// backend merges this guest's cart into the account. Null when none.
  Future<int?> storedGuestId();

  /// Drops the stored session, e.g. once the customer has signed in.
  Future<void> clear();
}

class GuestSessionManagerImpl implements GuestSessionManager {
  final GuestSessionRemoteDataSource remote;
  final GuestSessionLocalDataSource local;

  /// This device's FCM token, so the backend can push to the guest. Best
  /// effort: a missing or slow token never blocks the session.
  final Future<String?> Function() fcmToken;
  final DateTime Function() clock;
  final Duration fcmTokenTimeout;

  GuestSessionManagerImpl({
    required this.remote,
    required this.local,
    required this.fcmToken,
    DateTime Function()? clock,
    this.fcmTokenTimeout = const Duration(seconds: 3),
  }) : clock = clock ?? DateTime.now;

  Future<GuestSession>? _inFlight;

  @override
  Future<GuestSession> ensure() async {
    final GuestSession? stored = await _readStored();
    if (stored != null && stored.isUsableAt(clock())) return stored;
    return _create();
  }

  @override
  Future<GuestSession> renew(GuestSession? rejected) async {
    final GuestSession? stored = await _readStored();
    if (stored != null && stored != rejected && stored.isUsableAt(clock())) {
      return stored;
    }
    return _create();
  }

  @override
  Future<int?> storedGuestId() async => (await _readStored())?.guestId;

  @override
  Future<void> clear() => local.delete();

  /// One backend request at a time — a screen firing several cart calls at
  /// once must not mint several guests.
  Future<GuestSession> _create() =>
      _inFlight ??= _request().whenComplete(() => _inFlight = null);

  Future<GuestSession> _request() async {
    final GuestSession session = await remote.request(
      fcmToken: await _fcmTokenOrNull(),
    );
    try {
      await local.write(session);
    } catch (_) {
      // Keystore unavailable: the session still works for this request;
      // the next one simply asks for another.
    }
    return session;
  }

  Future<GuestSession?> _readStored() async {
    try {
      return await local.read();
    } catch (_) {
      return null;
    }
  }

  Future<String?> _fcmTokenOrNull() async {
    try {
      final String? token = await fcmToken().timeout(fcmTokenTimeout);
      return token == null || token.isEmpty ? null : token;
    } catch (_) {
      // No Firebase, no APNs token yet, or a timeout.
      return null;
    }
  }
}
