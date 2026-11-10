import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'guest_session.dart';
import 'guest_session_model.dart';

/// The guest token is a credential, so it lives in the Keychain/Keystore —
/// the same store as the access token, so `AppSecureStorage.clearAll` (a
/// 401) wipes it too.
abstract class GuestSessionLocalDataSource {
  /// Null when nothing is stored or the stored copy is unreadable.
  Future<GuestSession?> read();

  Future<void> write(GuestSession session);

  Future<void> delete();
}

class GuestSessionLocalDataSourceImpl implements GuestSessionLocalDataSource {
  final FlutterSecureStorage storage;

  const GuestSessionLocalDataSourceImpl({required this.storage});

  static const String _key = 'guestSession';

  @override
  Future<GuestSession?> read() async {
    final String? raw = await storage.read(key: _key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return GuestSessionModel.fromJson(jsonDecode(raw));
    } catch (_) {
      // Corrupt or from an older shape — a fresh session replaces it.
      return null;
    }
  }

  @override
  Future<void> write(GuestSession session) => storage.write(
    key: _key,
    value: jsonEncode(GuestSessionModel.toJson(session)),
  );

  @override
  Future<void> delete() => storage.delete(key: _key);
}
