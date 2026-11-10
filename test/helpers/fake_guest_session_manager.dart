import 'package:ssm/core/guest/guest_session.dart';
import 'package:ssm/core/guest/guest_session_manager.dart';

/// Hands out [session] (or throws [error]) and records what was asked.
class FakeGuestSessionManager implements GuestSessionManager {
  GuestSession? session;
  Object? error;

  /// What [renew] switches [session] to, as the backend would.
  GuestSession? renewed;

  int ensureCalls = 0;
  final List<GuestSession?> renewCalls = <GuestSession?>[];
  int clearCalls = 0;

  FakeGuestSessionManager({this.session, this.renewed});

  @override
  Future<GuestSession> ensure() async {
    ensureCalls++;
    if (error case final Object e) throw e;
    return session!;
  }

  @override
  Future<GuestSession> renew(GuestSession? rejected) async {
    renewCalls.add(rejected);
    if (error case final Object e) throw e;
    session = renewed ?? session;
    return session!;
  }

  @override
  Future<int?> storedGuestId() async => session?.guestId;

  @override
  Future<void> clear() async {
    clearCalls++;
    session = null;
  }
}
