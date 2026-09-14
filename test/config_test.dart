import 'dart:convert';
import 'dart:io';

import 'package:flutter_base/config/env/app_env.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the two contracts that break silently at runtime rather than at
/// compile time: `.env` parsing, and translation-key parity between the JSON
/// files and `Strings`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppEnv', () {
    setUpAll(() => AppEnv.load());

    test('loads values from the bundled .env', () {
      expect(AppEnv.appName, isNotEmpty);
      expect(AppEnv.baseUrl, startsWith('http'));
    });

    test('timeouts parse to positive durations', () {
      expect(AppEnv.connectTimeout, greaterThan(Duration.zero));
      expect(AppEnv.receiveTimeout, greaterThan(Duration.zero));
    });
  });

  group('Translations', () {
    Map<String, dynamic> load(String code) =>
        jsonDecode(File('lang/$code.json').readAsStringSync())
            as Map<String, dynamic>;

    test('en and ar declare exactly the same keys', () {
      final Set<String> en = load('en').keys.toSet();
      final Set<String> ar = load('ar').keys.toSet();
      expect(en.difference(ar), isEmpty, reason: 'keys missing from ar.json');
      expect(ar.difference(en), isEmpty, reason: 'keys missing from en.json');
    });

    test('no translation is blank', () {
      for (final String code in <String>['en', 'ar']) {
        load(code).forEach((String key, dynamic value) {
          expect(
            value.toString().trim(),
            isNotEmpty,
            reason: '$code.json has an empty value for "$key"',
          );
        });
      }
    });

    test('every key referenced by Strings exists in the JSON', () {
      final Set<String> declared = load('en').keys.toSet();
      final String source = File(
        'lib/core/utils/values/strings.dart',
      ).readAsStringSync();

      final Iterable<String> referenced = RegExp(
        r"static const String _\w+ = '([a-z0-9_]+)';",
      ).allMatches(source).map((RegExpMatch m) => m.group(1)!);

      expect(referenced, isNotEmpty, reason: 'regex failed to match Strings');
      for (final String key in referenced) {
        expect(
          declared,
          contains(key),
          reason: 'Strings references "$key", missing from lang/*.json',
        );
      }
    });
  });
}
