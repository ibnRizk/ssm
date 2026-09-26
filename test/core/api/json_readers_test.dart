import 'package:flutter_base/core/api/json_readers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('jsonInt', () {
    test('reads ints, whole doubles and numeric strings', () {
      expect(jsonInt(7), 7);
      expect(jsonInt(7.0), 7);
      expect(jsonInt(' 7 '), 7);
    });

    test('is null for anything else', () {
      expect(jsonInt('seven'), isNull);
      expect(jsonInt(null), isNull);
      expect(jsonInt(<int>[7]), isNull);
    });
  });

  group('jsonDouble', () {
    test('reads numbers and numeric strings', () {
      expect(jsonDouble(24.71), 24.71);
      expect(jsonDouble(24), 24.0);
      expect(jsonDouble('24.7100'), 24.71);
    });

    test('is null for a non-numeric string', () {
      expect(jsonDouble('north'), isNull);
    });
  });

  group('jsonString', () {
    test('trims', () {
      expect(jsonString('  Sara '), 'Sara');
    });

    test('is null when blank or not a string', () {
      expect(jsonString('   '), isNull);
      expect(jsonString(7), isNull);
    });
  });
}
