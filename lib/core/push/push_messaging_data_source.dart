import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'local_notification_presenter.dart';
import 'push_banner_copy.dart';
import 'push_payload.dart';

/// The device side of push: FCM plus the local banners drawn for it.
abstract class PushMessagingDataSource {
  /// False until Firebase is configured for this build — every other call
  /// is then a no-op (streams stay empty, the token is null).
  bool get isAvailable;

  /// Call once from `main()`, after `Firebase.initializeApp`.
  Future<void> initialize();

  /// The OS prompt (iOS; Android 13+). Asked once — later calls return the
  /// stored answer without prompting.
  Future<bool> requestPermission();

  Future<String?> getToken();

  Stream<String> get onTokenRefresh;

  /// Pushes received while the app is in the foreground.
  Stream<PushPayload> get foregroundMessages;

  /// Banners (ours or the OS's) tapped while the app is running.
  Stream<PushPayload> get taps;

  /// The push whose banner launched the app from killed. Answered once;
  /// later calls return null so the same tap isn't routed twice.
  Future<PushPayload?> takeLaunchPayload();

  Future<void> showBanner(PushPayload payload, PushBannerCopy copy);
}

class FirebasePushMessagingDataSource implements PushMessagingDataSource {
  final LocalNotificationPresenter presenter;

  FirebasePushMessagingDataSource({required this.presenter});

  final StreamController<PushPayload> _taps =
      StreamController<PushPayload>.broadcast();
  bool _launchTaken = false;

  /// `FirebaseMessaging.instance` throws until a Firebase app exists.
  @override
  bool get isAvailable => Firebase.apps.isNotEmpty;

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  @override
  Future<void> initialize() async {
    if (!isAvailable) return;
    await presenter.initialize(onTap: _taps.add);
    // Only reached if the backend ever adds a `notification` block (the OS
    // draws those itself); data-only pushes are tapped via our banners.
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) => _taps.add(PushPayload.fromData(message.data)),
    );
    // We draw foreground banners ourselves — stop iOS drawing a second one
    // for a push that has a `notification` block.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: false,
    );
  }

  @override
  Future<bool> requestPermission() async {
    if (!isAvailable) return false;
    final NotificationSettings settings = await _messaging.requestPermission();
    return switch (settings.authorizationStatus) {
      AuthorizationStatus.authorized || AuthorizationStatus.provisional => true,
      _ => false,
    };
  }

  @override
  Future<String?> getToken() async =>
      isAvailable ? _messaging.getToken() : null;

  @override
  Stream<String> get onTokenRefresh =>
      isAvailable ? _messaging.onTokenRefresh : const Stream<String>.empty();

  @override
  Stream<PushPayload> get foregroundMessages => isAvailable
      ? FirebaseMessaging.onMessage.map(_payloadOf)
      : const Stream<PushPayload>.empty();

  @override
  Stream<PushPayload> get taps => _taps.stream;

  @override
  Future<PushPayload?> takeLaunchPayload() async {
    if (!isAvailable || _launchTaken) return null;
    _launchTaken = true;
    final RemoteMessage? initial = await _messaging.getInitialMessage();
    if (initial != null) return PushPayload.fromData(initial.data);
    return presenter.launchPayload();
  }

  @override
  Future<void> showBanner(PushPayload payload, PushBannerCopy copy) =>
      presenter.show(payload, copy);

  /// A `notification` block's text wins over the data's — it's what the
  /// backend meant the banner to say.
  static PushPayload _payloadOf(RemoteMessage message) {
    final PushPayload data = PushPayload.fromData(message.data);
    final RemoteNotification? shown = message.notification;
    if (shown == null) return data;
    return PushPayload.fromData(<String, dynamic>{
      ...data.toData(),
      'title': ?shown.title,
      'body': ?shown.body,
    });
  }
}
