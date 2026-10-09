import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Typed access to the values in `.env`.
///
/// Call [load] once in `main()`, *before* [ServiceLocator.init] — the Dio
/// client reads [baseUrl] in its constructor.
///
/// For flavors, ship `.env.staging` / `.env.production` alongside `.env`,
/// declare them under `flutter: assets:` in pubspec.yaml, and select one with
/// `flutter run --dart-define=ENV_FILE=.env.production`.
abstract class AppEnv {
  static Future<void> load() async {
    const String fileName = String.fromEnvironment(
      'ENV_FILE',
      defaultValue: '.env',
    );
    await dotenv.load(fileName: fileName);
  }

  static String get appName => dotenv.get('APP_NAME', fallback: 'ssm');

  static String get baseUrl => dotenv.get('BASE_URL', fallback: '');

  static bool get enableNetworkLogs =>
      dotenv.get('ENABLE_NETWORK_LOGS', fallback: 'false').toLowerCase() ==
      'true';

  // --- Realtime (Pusher protocol: Laravel Reverb / soketi / Pusher) ---
  // The app key is public by design (every client sends it in the socket
  // URL); the app *secret* stays on the server. Realtime switches itself off
  // while the key or host is blank, so builds without them still run.

  static String get pusherAppKey => dotenv.get('PUSHER_APP_KEY', fallback: '');

  static String get pusherHost => dotenv.get('PUSHER_HOST', fallback: '');

  static int get pusherPort =>
      int.tryParse(dotenv.get('PUSHER_PORT', fallback: '')) ?? 443;

  /// `wss` in production; `ws` only for a local server without TLS.
  static String get pusherScheme =>
      dotenv.get('PUSHER_SCHEME', fallback: 'wss');

  static bool get isRealtimeConfigured =>
      pusherAppKey.isNotEmpty && pusherHost.isNotEmpty;

  static Duration get connectTimeout => _duration('CONNECT_TIMEOUT_MS', 30000);

  static Duration get receiveTimeout => _duration('RECEIVE_TIMEOUT_MS', 30000);

  static Duration _duration(String key, int fallbackMs) => Duration(
    milliseconds: int.tryParse(dotenv.get(key, fallback: '')) ?? fallbackMs,
  );
}
