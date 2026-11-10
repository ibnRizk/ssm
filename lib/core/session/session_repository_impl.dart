import '../services/local_storage/app_secure_storage.dart';
import '../services/local_storage/app_shared_preferences.dart';
import 'session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  final AppSecureStorage secureStorage;
  final AppSharedPreferences sharedPreferences;

  const SessionRepositoryImpl({
    required this.secureStorage,
    required this.sharedPreferences,
  });

  @override
  Future<bool> isSignedIn() async {
    try {
      final String? token = await secureStorage.getAccessToken();
      return token != null && token.isNotEmpty;
    } catch (_) {
      // Keystore unreadable: no request could carry the token either.
      return false;
    }
  }

  @override
  bool get isGuestModeChosen => sharedPreferences.getGuestMode();

  @override
  Future<void> chooseGuestMode() async {
    try {
      await sharedPreferences.saveGuestMode(true);
    } catch (_) {
      // Only costs the shortcut on the next launch — browsing still works.
    }
  }
}
