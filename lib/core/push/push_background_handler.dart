import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/local_storage/app_shared_preferences.dart';
import 'local_notification_presenter.dart';
import 'push_banner_copy.dart';
import 'push_payload.dart';

/// FCM's entry point for a push that arrives while the app is in the
/// background or killed. Runs in a fresh isolate: nothing from `main()` —
/// DI, localization, the router — exists here, so it only draws the banner.
/// Tapping it starts (or resumes) the app, which routes from the payload.
///
/// Must stay a top-level function and keep the pragma, or release builds
/// tree-shake it away.
///
/// iOS only wakes the app for a data-only push sent with
/// `content-available: 1` (and `apns-priority: 5`), and may throttle those;
/// that part is the backend's to send.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    // A push with a `notification` block was already shown by the OS.
    if (message.notification != null) return;

    final PushPayload payload = PushPayload.fromData(message.data);
    final AppSharedPreferences preferences = AppSharedPreferencesImpl(
      instance: await SharedPreferences.getInstance(),
    );
    final LocalNotificationPresenter presenter = LocalNotificationPresenter();
    await presenter.initialize();
    await presenter.show(
      payload,
      PushBannerCopy.forPayload(
        payload,
        languageCode: preferences.getLanguageCode().name,
      ),
    );
  } catch (_) {
    // Nothing to report to from here; the inbox still has the notification.
  }
}
