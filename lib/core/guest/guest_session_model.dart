import '../api/json_readers.dart';
import '../error/exceptions.dart';
import 'guest_session.dart';

/// JSON for [GuestSession] — the backend's answer and the stored copy share
/// one shape: `{guest_id, guest_token, expires_at}`.
abstract final class GuestSessionModel {
  /// Throws [ServerException] when the id or token is missing: without both
  /// the session can't authorize anything.
  static GuestSession fromJson(dynamic json) {
    if (json is! Map) throw const ServerException();
    final int? guestId = jsonInt(json['guest_id']);
    final String? token = jsonString(json['guest_token']);
    if (guestId == null || token == null) throw const ServerException();
    final String? expiresAt = jsonString(json['expires_at']);
    return GuestSession(
      guestId: guestId,
      token: token,
      expiresAt: expiresAt == null ? null : DateTime.tryParse(expiresAt),
    );
  }

  static Map<String, dynamic> toJson(GuestSession session) => <String, dynamic>{
    'guest_id': session.guestId,
    'guest_token': session.token,
    'expires_at': session.expiresAt?.toIso8601String(),
  };
}
