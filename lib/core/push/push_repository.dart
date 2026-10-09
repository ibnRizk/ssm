import 'package:dartz/dartz.dart';

import '../error/failures.dart';
import 'notification_target.dart';
import 'push_payload.dart';

/// Push for the signed-in customer: registering this device with the
/// backend, and what arrives or is tapped.
///
/// In `core/` because two features use it — auth unregisters the device on
/// logout, notifications registers it and routes the taps.
abstract class PushRepository {
  /// Call once from `main()`. Starts drawing banners for foreground pushes.
  Future<void> initialize();

  /// Foreground pushes, after their banner was shown.
  Stream<PushPayload> get foregroundMessages;

  /// Where each tapped banner leads, while the app is running.
  Stream<NotificationTarget> get taps;

  /// Where the banner that launched the app from killed leads, if one did.
  /// Answered once.
  Future<NotificationTarget?> takeLaunchTarget();

  /// FCM rotated this device's token; [registerDevice] again.
  Stream<void> get tokenRefreshes;

  /// Asks the OS for permission (once), then sends this device's FCM token
  /// with `PUT /customer/cm-firebase-token`. The token is sent even when
  /// permission is denied: the backend still counts unread notifications,
  /// and the customer may allow banners later in Settings.
  /// [PushUnavailableFailure] while Firebase isn't configured.
  Future<Either<Failure, Unit>> registerDevice();

  /// `POST /customer/remove-fcm-token`, so pushes for this customer stop
  /// reaching this device. Call while still signed in — it needs the bearer.
  Future<Either<Failure, Unit>> unregisterDevice();
}
