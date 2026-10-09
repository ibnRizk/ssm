import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ssm/core/api/api_endpoints.dart';
import 'package:ssm/core/error/exceptions.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/core/push/notification_target.dart';
import 'package:ssm/core/push/push_banner_copy.dart';
import 'package:ssm/core/push/push_messaging_data_source.dart';
import 'package:ssm/core/push/push_payload.dart';
import 'package:ssm/core/push/push_repository_impl.dart';
import 'package:ssm/core/push/push_token_remote_data_source.dart';
import 'package:ssm/core/services/local_storage/app_shared_preferences.dart';

import '../../helpers/fake_dio_consumer.dart';

class _FakeMessaging implements PushMessagingDataSource {
  bool available = true;
  String? token = 'fcm-token';
  bool throwOnToken = false;
  int permissionRequests = 0;
  PushPayload? launch;
  final List<(PushPayload, PushBannerCopy)> banners =
      <(PushPayload, PushBannerCopy)>[];

  final StreamController<PushPayload> foreground =
      StreamController<PushPayload>.broadcast(sync: true);
  final StreamController<PushPayload> tapController =
      StreamController<PushPayload>.broadcast(sync: true);

  @override
  bool get isAvailable => available;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return true;
  }

  @override
  Future<String?> getToken() async {
    if (throwOnToken) throw Exception('SERVICE_NOT_AVAILABLE');
    return token;
  }

  @override
  Stream<String> get onTokenRefresh => const Stream<String>.empty();

  @override
  Stream<PushPayload> get foregroundMessages => foreground.stream;

  @override
  Stream<PushPayload> get taps => tapController.stream;

  @override
  Future<PushPayload?> takeLaunchPayload() async => launch;

  @override
  Future<void> showBanner(PushPayload payload, PushBannerCopy copy) async =>
      banners.add((payload, copy));
}

void main() {
  late _FakeMessaging messaging;
  late FakeDioConsumer consumer;
  late PushRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'languageCode': 'en',
    });
    messaging = _FakeMessaging();
    consumer = FakeDioConsumer(response: <String, dynamic>{});
    repository = PushRepositoryImpl(
      messaging: messaging,
      remote: PushTokenRemoteDataSourceImpl(consumer: consumer),
      preferences: AppSharedPreferencesImpl(
        instance: await SharedPreferences.getInstance(),
      ),
    );
  });

  group('registerDevice', () {
    test('asks permission, then PUTs the token', () async {
      final Either<Failure, Unit> result = await repository.registerDevice();

      expect(result, const Right<Failure, Unit>(unit));
      expect(messaging.permissionRequests, 1);
      expect(consumer.lastVerb, 'PUT');
      expect(consumer.lastPath, ApiEndpoints.fcmToken);
      expect(consumer.lastBody, <String, dynamic>{
        'cm_firebase_token': 'fcm-token',
      });
    });

    test('without Firebase it reports push as unavailable', () async {
      messaging.available = false;

      expect(
        await repository.registerDevice(),
        const Left<Failure, Unit>(PushUnavailableFailure()),
      );
      expect(consumer.lastVerb, isNull);
    });

    test('a device that yields no token sends nothing', () async {
      messaging.token = null;

      expect((await repository.registerDevice()).isLeft(), isTrue);
      expect(consumer.lastVerb, isNull);
    });

    test('an FCM error becomes PushUnavailableFailure', () async {
      messaging.throwOnToken = true;

      final Either<Failure, Unit> result = await repository.registerDevice();

      expect(
        result.fold((Failure f) => f, (_) => null),
        isA<PushUnavailableFailure>(),
      );
    });

    test('an API error is mapped at the boundary', () async {
      consumer.error = const UnauthorizedException();

      final Either<Failure, Unit> result = await repository.registerDevice();

      expect(
        result.fold((Failure f) => f, (_) => null),
        isA<UnauthorizedFailure>(),
      );
    });
  });

  group('unregisterDevice', () {
    test('POSTs remove-fcm-token', () async {
      await repository.unregisterDevice();

      expect(consumer.lastVerb, 'POST');
      expect(consumer.lastPath, ApiEndpoints.removeFcmToken);
    });

    test('is a success with nothing to do without Firebase', () async {
      messaging.available = false;

      expect(
        await repository.unregisterDevice(),
        const Right<Failure, Unit>(unit),
      );
      expect(consumer.lastVerb, isNull);
    });
  });

  test('a foreground push draws one banner however many listen', () async {
    await repository.initialize();
    final List<PushPayload> a = <PushPayload>[];
    final List<PushPayload> b = <PushPayload>[];
    repository.foregroundMessages.listen(a.add);
    repository.foregroundMessages.listen(b.add);

    messaging.foreground.add(
      const PushPayload(entityType: 'order', entityId: '42'),
    );
    await pumpEventQueue();

    expect(messaging.banners, hasLength(1));
    expect(messaging.banners.single.$2.title, 'Order update');
    expect(a, hasLength(1));
    expect(b, hasLength(1));
  });

  test('taps and the launch push resolve to targets', () async {
    final List<NotificationTarget> taps = <NotificationTarget>[];
    repository.taps.listen(taps.add);
    messaging
      ..launch = const PushPayload(entityType: 'parcel')
      ..tapController.add(
        const PushPayload(entityType: 'order', entityId: '3'),
      );

    expect(taps, <NotificationTarget>[const OrderTarget(3)]);
    expect(await repository.takeLaunchTarget(), const ParcelsTarget());
  });
}
