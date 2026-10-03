import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/api/api_endpoints.dart';
import 'package:ssm/core/app_config/app_config_model.dart';
import 'package:ssm/core/app_config/app_config_remote_data_source.dart';
import 'package:ssm/core/app_config/app_version.dart';
import 'package:ssm/core/error/exceptions.dart';

import '../../helpers/fake_dio_consumer.dart';

/// The production response on 2026-10-03, legal bodies shortened.
Map<String, dynamic> _body({
  dynamic maintenanceMode = false,
  dynamic android = 0,
  dynamic ios = 0,
  dynamic androidStore,
}) => <String, dynamic>{
  'support': <String, dynamic>{
    'phone': '+201119842314',
    'email': 'admin@ssm.com',
  },
  'legal': <String, dynamic>{'terms': '<p>Terms</p>', 'privacy': '<h2>P</h2>'},
  'application': <String, dynamic>{
    'name': 'SSM',
    'currency': 'SAR',
    'timezone': 'UTC',
    'maintenance_mode': maintenanceMode,
    'minimum_versions': <String, dynamic>{'android': android, 'ios': ios},
    'store_urls': <String, dynamic>{'android': androidStore, 'ios': null},
  },
};

Future<AppConfigModel> _parse(dynamic body) => AppConfigRemoteDataSourceImpl(
  consumer: FakeDioConsumer(response: body),
).getConfig();

void main() {
  test('reads the customer config endpoint', () async {
    final FakeDioConsumer consumer = FakeDioConsumer(response: _body());

    await AppConfigRemoteDataSourceImpl(consumer: consumer).getConfig();

    expect(consumer.lastPath, ApiEndpoints.customerConfig);
  });

  test('parses the production response', () async {
    final AppConfigModel config = await _parse(_body());

    expect(
      config,
      const AppConfigModel(
        maintenanceMode: false,
        minimumAndroidVersion: AppVersion(<int>[0]),
        minimumIosVersion: AppVersion(<int>[0]),
        supportPhone: '+201119842314',
        supportEmail: 'admin@ssm.com',
        termsHtml: '<p>Terms</p>',
        privacyHtml: '<h2>P</h2>',
      ),
    );
  });

  test('reads a numeric minimum version', () async {
    final AppConfigModel config = await _parse(_body(android: 1.2));

    expect(config.minimumAndroidVersion, const AppVersion(<int>[1, 2]));
  });

  test('reads a string minimum version', () async {
    final AppConfigModel config = await _parse(_body(ios: '2.1.0'));

    expect(config.minimumIosVersion, const AppVersion(<int>[2, 1, 0]));
  });

  test('reads maintenance mode sent as 1', () async {
    final AppConfigModel config = await _parse(_body(maintenanceMode: 1));

    expect(config.maintenanceMode, isTrue);
  });

  test('keeps an https store link', () async {
    const String url = 'https://play.google.com/store/apps/details?id=x';
    final AppConfigModel config = await _parse(_body(androidStore: url));

    expect(config.androidStoreUrl, url);
  });

  test('drops a store link that is not http(s)', () async {
    final AppConfigModel config = await _parse(
      _body(androidStore: 'javascript:alert(1)'),
    );

    expect(config.androidStoreUrl, isNull);
  });

  test('throws when the body has no application object', () {
    expect(
      _parse(<String, dynamic>{'support': <String, dynamic>{}}),
      throwsA(isA<ServerException>()),
    );
  });
}
