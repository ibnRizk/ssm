import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/utils/number_input.dart';

void main() {
  group('NumberInput.normalizeDigits', () {
    test('Eastern-Arabic and Persian digits become Western ones', () {
      expect(NumberInput.normalizeDigits('٠١٢٣٤٥٦٧٨٩'), '0123456789');
      expect(NumberInput.normalizeDigits('۰۱۲۳۴۵۶۷۸۹'), '0123456789');
    });

    test('everything else is left as it is', () {
      expect(NumberInput.normalizeDigits('SAR 12.5'), 'SAR 12.5');
    });
  });

  group('NumberInput.parseAmount', () {
    test('reads a plain amount', () {
      expect(NumberInput.parseAmount('250'), 250);
      expect(NumberInput.parseAmount(' 99.50 '), 99.5);
    });

    test('a comma is a thousands separator, never a decimal one', () {
      expect(NumberInput.parseAmount('1,000'), 1000);
      expect(NumberInput.parseAmount('1,250.75'), 1250.75);
    });

    test('reads an amount typed on an Arabic keyboard', () {
      expect(NumberInput.parseAmount('٣٠٠'), 300);
      expect(NumberInput.parseAmount('١٢٫٥'), 12.5);
      expect(NumberInput.parseAmount('١٬٠٠٠'), 1000);
    });

    test('blank is none', () {
      expect(NumberInput.parseAmount('  '), isNull);
    });

    test('text that is not an amount is none, not a guess', () {
      expect(NumberInput.parseAmount('1.2.3'), isNull);
      expect(NumberInput.parseAmount('.5'), isNull);
      expect(NumberInput.parseAmount('12.345'), isNull);
    });
  });
}
