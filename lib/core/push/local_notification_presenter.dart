import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'push_banner_copy.dart';
import 'push_payload.dart';

/// Draws push banners with `flutter_local_notifications` — the backend's
/// pushes are data-only, so the OS never shows anything by itself.
///
/// Used from two isolates: the app's, and the one FCM starts for a push
/// that arrives in the background or while the app is killed. Each must
/// [initialize] its own instance before showing.
class LocalNotificationPresenter {
  final FlutterLocalNotificationsPlugin _plugin;

  LocalNotificationPresenter({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  /// High importance so Android shows a heads-up banner, not just an icon.
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'ssm_updates',
    'Orders and updates',
    description: 'Order, parcel and account updates from SSM.',
    importance: Importance.high,
  );

  bool _initialized = false;

  /// [onTap] receives the tapped banner's payload — only in the app's
  /// isolate; the background isolate has nothing to route.
  Future<void> initialize({ValueChanged<PushPayload>? onTap}) async {
    if (_initialized) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        // Must be a white-on-transparent drawable to render well on Android
        // 5+; the launcher icon works but shows as a grey square on some
        // devices. Swap for a dedicated `ic_notification` when design has one.
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Permission is asked by `FirebaseMessaging.requestPermission`, at
        // sign-in — not by this plugin at app start.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: onTap == null
          ? null
          : (NotificationResponse response) {
              final PushPayload? payload = decodePayload(response.payload);
              if (payload != null) onTap(payload);
            },
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
    _initialized = true;
  }

  /// The banner that launched the app from killed, if one did.
  Future<PushPayload?> launchPayload() async {
    final NotificationAppLaunchDetails? details = await _plugin
        .getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return null;
    return decodePayload(details.notificationResponse?.payload);
  }

  Future<void> show(PushPayload payload, PushBannerCopy copy) => _plugin.show(
    id: bannerId(payload),
    title: copy.title,
    body: copy.body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.high,
        priority: Priority.high,
        // Long bodies wrap instead of being cut to one line.
        styleInformation: BigTextStyleInformation(copy.body),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
    payload: jsonEncode(payload.toData()),
  );

  /// One banner per server notification: a re-delivered push replaces its
  /// banner instead of stacking a copy. Pushes without an id get their own.
  @visibleForTesting
  static int bannerId(PushPayload payload) {
    final String? id = payload.notificationId;
    final int raw = id == null
        ? DateTime.now().millisecondsSinceEpoch
        : int.tryParse(id) ?? id.hashCode;
    // Android notification ids are 32-bit signed ints.
    return raw & 0x7fffffff;
  }

  @visibleForTesting
  static PushPayload? decodePayload(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final dynamic decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic>
          ? PushPayload.fromData(decoded)
          : null;
    } on FormatException {
      return null;
    }
  }
}
