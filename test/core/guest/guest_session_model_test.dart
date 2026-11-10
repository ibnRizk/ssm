import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/error/exceptions.dart';
import 'package:ssm/core/guest/guest_session.dart';
import 'package:ssm/core/guest/guest_session_model.dart';

void main() {
  group('GuestSessionModel.fromJson', () {
    test('reads the backend answer', () {
      final GuestSession session = GuestSessionModel.fromJson(<String, dynamic>{
        'guest_id': 123,
        'guest_token': 'returned-once-only',
        'expires_at': '2027-02-08T00:00:00+00:00',
      });

      expect(session.guestId, 123);
      expect(session.token, 'returned-once-only');
      expect(session.expiresAt, DateTime.utc(2027, 2, 8));
    });

    test('accepts a string guest id', () {
      final GuestSession session = GuestSessionModel.fromJson(<String, dynamic>{
        'guest_id': '7',
        'guest_token': 'tok',
      });

      expect(session.guestId, 7);
    });

    test('treats a missing expiry as none', () {
      final GuestSession session = GuestSessionModel.fromJson(<String, dynamic>{
        'guest_id': 7,
        'guest_token': 'tok',
      });

      expect(session.expiresAt, isNull);
    });

    test('rejects an answer without a token', () {
      expect(
        () => GuestSessionModel.fromJson(<String, dynamic>{'guest_id': 7}),
        throwsA(isA<ServerException>()),
      );
    });

    test('rejects an answer without a guest id', () {
      expect(
        () => GuestSessionModel.fromJson(<String, dynamic>{'guest_token': 't'}),
        throwsA(isA<ServerException>()),
      );
    });

    test('rejects a non-object answer', () {
      expect(
        () => GuestSessionModel.fromJson('oops'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  test('toJson round-trips through fromJson', () {
    final GuestSession session = GuestSession(
      guestId: 9,
      token: 'tok',
      expiresAt: DateTime.utc(2027, 1, 1),
    );

    expect(
      GuestSessionModel.fromJson(GuestSessionModel.toJson(session)),
      session,
    );
  });

  group('GuestSession.isUsableAt', () {
    final DateTime expiry = DateTime.utc(2027, 1, 1, 12);
    final GuestSession session = GuestSession(
      guestId: 1,
      token: 't',
      expiresAt: expiry,
    );

    test('is usable well before expiry', () {
      expect(
        session.isUsableAt(expiry.subtract(const Duration(hours: 1))),
        isTrue,
      );
    });

    test('is not usable within the safety margin', () {
      expect(
        session.isUsableAt(expiry.subtract(const Duration(seconds: 30))),
        isFalse,
      );
    });

    test('is not usable after expiry', () {
      expect(
        session.isUsableAt(expiry.add(const Duration(seconds: 1))),
        isFalse,
      );
    });

    test('without an expiry is always usable', () {
      const GuestSession open = GuestSession(guestId: 1, token: 't');

      expect(open.isUsableAt(DateTime.utc(2100)), isTrue);
    });
  });
}
