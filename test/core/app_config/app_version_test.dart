import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/app_config/app_version.dart';

AppVersion _v(String text) => AppVersion.tryParse(text)!;

void main() {
  group('AppVersion.tryParse', () {
    test('reads dotted numbers', () {
      expect(AppVersion.tryParse('1.4.2'), const AppVersion(<int>[1, 4, 2]));
    });

    test('ignores the build number', () {
      expect(AppVersion.tryParse('1.4.2+7'), const AppVersion(<int>[1, 4, 2]));
    });

    test('ignores a pre-release tag', () {
      expect(
        AppVersion.tryParse('2.0.0-beta'),
        const AppVersion(<int>[2, 0, 0]),
      );
    });

    test('ignores a leading v', () {
      expect(AppVersion.tryParse('v1.4'), const AppVersion(<int>[1, 4]));
    });

    test('rejects text that is not dotted numbers', () {
      expect(AppVersion.tryParse('latest'), isNull);
    });

    test('rejects an empty string', () {
      expect(AppVersion.tryParse(' '), isNull);
    });

    test('rejects an empty part', () {
      expect(AppVersion.tryParse('1..2'), isNull);
    });
  });

  group('AppVersion.compareTo', () {
    test('compares numerically, not as text', () {
      expect(_v('1.10.0') < _v('1.9.0'), isFalse);
    });

    test('reads missing parts as zero', () {
      expect(_v('1.4').compareTo(_v('1.4.0')), 0);
    });

    test('an older patch is lower', () {
      expect(_v('1.4.1') < _v('1.4.2'), isTrue);
    });

    test('any version is above a zero minimum', () {
      expect(_v('1.0.0') < _v('0'), isFalse);
    });
  });
}
