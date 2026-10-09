import 'dart:async';

import 'package:dartz/dartz.dart';

import '../api/safe_api_call.dart';
import '../error/failures.dart';
import '../services/local_storage/app_shared_preferences.dart';
import 'notification_target.dart';
import 'push_banner_copy.dart';
import 'push_messaging_data_source.dart';
import 'push_payload.dart';
import 'push_repository.dart';
import 'push_token_remote_data_source.dart';

class PushRepositoryImpl implements PushRepository {
  final PushMessagingDataSource messaging;
  final PushTokenRemoteDataSource remote;
  final AppSharedPreferences preferences;

  PushRepositoryImpl({
    required this.messaging,
    required this.remote,
    required this.preferences,
  });

  final StreamController<PushPayload> _foreground =
      StreamController<PushPayload>.broadcast();
  StreamSubscription<PushPayload>? _foregroundSub;

  @override
  Future<void> initialize() async {
    if (_foregroundSub != null) return;
    await messaging.initialize();
    // Subscribed once here, not per listener, so a push draws exactly one
    // banner however many screens listen to [foregroundMessages].
    _foregroundSub = messaging.foregroundMessages.listen((
      PushPayload payload,
    ) async {
      try {
        await messaging.showBanner(
          payload,
          PushBannerCopy.forPayload(
            payload,
            languageCode: preferences.getLanguageCode().name,
          ),
        );
      } catch (_) {
        // A banner that can't be drawn mustn't stop the badge updating.
      }
      _foreground.add(payload);
    });
  }

  @override
  Stream<PushPayload> get foregroundMessages => _foreground.stream;

  @override
  Stream<NotificationTarget> get taps =>
      messaging.taps.map((PushPayload payload) => payload.target);

  @override
  Future<NotificationTarget?> takeLaunchTarget() async {
    try {
      return (await messaging.takeLaunchPayload())?.target;
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<void> get tokenRefreshes => messaging.onTokenRefresh;

  @override
  Future<Either<Failure, Unit>> registerDevice() async {
    if (!messaging.isAvailable) return const Left(PushUnavailableFailure());
    final String? token;
    try {
      await messaging.requestPermission();
      token = await messaging.getToken();
    } catch (error) {
      // No Play Services, APNs not set up, or the user's network blocks FCM.
      return Left(PushUnavailableFailure(message: error.toString()));
    }
    if (token == null || token.isEmpty) {
      return const Left(PushUnavailableFailure());
    }
    final String deviceToken = token;
    return safeApiCall(() async {
      await remote.register(deviceToken);
      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> unregisterDevice() async {
    // A device that never got a token was never registered.
    if (!messaging.isAvailable) return const Right(unit);
    return safeApiCall(() async {
      await remote.remove();
      return unit;
    });
  }
}
