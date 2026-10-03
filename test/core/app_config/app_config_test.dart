import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/app_config/app_config.dart';
import 'package:ssm/core/app_config/app_version.dart';
import 'package:ssm/core/app_config/installed_app.dart';

const AppConfig _config = AppConfig(
  maintenanceMode: false,
  minimumAndroidVersion: AppVersion(<int>[1, 2, 0]),
  minimumIosVersion: AppVersion(<int>[2, 0, 0]),
  androidStoreUrl: 'https://play.google.com/store/apps/details?id=com.ssm.user',
);

InstalledApp _app(String version, AppPlatform platform) =>
    InstalledApp(version: AppVersion.tryParse(version), platform: platform);

void main() {
  group('AppConfig.requiresUpdate', () {
    test('when the build is below its platform minimum', () {
      expect(
        _config.requiresUpdate(_app('1.1.9', AppPlatform.android)),
        isTrue,
      );
    });

    test('not when the build equals the minimum', () {
      expect(
        _config.requiresUpdate(_app('1.2.0', AppPlatform.android)),
        isFalse,
      );
    });

    test('checks the minimum of the installed platform', () {
      expect(_config.requiresUpdate(_app('1.5.0', AppPlatform.ios)), isTrue);
    });

    test('not when the platform has no minimum', () {
      const AppConfig config = AppConfig(maintenanceMode: false);
      expect(
        config.requiresUpdate(_app('0.0.1', AppPlatform.android)),
        isFalse,
      );
    });

    test('not when the installed version is unknown', () {
      const InstalledApp app = InstalledApp(
        version: null,
        platform: AppPlatform.android,
      );
      expect(_config.requiresUpdate(app), isFalse);
    });

    test('not on platforms without a store', () {
      expect(_config.requiresUpdate(_app('0.0.1', AppPlatform.other)), isFalse);
    });
  });

  test('storeUrlFor picks the platform link', () {
    expect(_config.storeUrlFor(AppPlatform.android), _config.androidStoreUrl);
  });
}
