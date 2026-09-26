import 'package:flutter_base/features/auth/domain/utils/saudi_phone.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SaudiPhone.toE164', () {
    test('local form with leading zero', () {
      expect(SaudiPhone.toE164('0512345678'), '+966512345678');
    });

    test('local form without leading zero', () {
      expect(SaudiPhone.toE164('512345678'), '+966512345678');
    });

    test('spaced input', () {
      expect(SaudiPhone.toE164('05 1234 5678'), '+966512345678');
    });

    test('already international with plus', () {
      expect(SaudiPhone.toE164('+966512345678'), '+966512345678');
    });

    test('international with 00 prefix', () {
      expect(SaudiPhone.toE164('00966512345678'), '+966512345678');
    });
  });

  group('SaudiPhone.isValid', () {
    test('accepts a 05 mobile number', () {
      expect(SaudiPhone.isValid('0512345678'), isTrue);
    });

    test('rejects a landline (not starting with 5)', () {
      expect(SaudiPhone.isValid('0112345678'), isFalse);
    });

    test('rejects a number that is too short', () {
      expect(SaudiPhone.isValid('05123'), isFalse);
    });

    test('rejects a number that is too long', () {
      expect(SaudiPhone.isValid('05123456789'), isFalse);
    });

    test('rejects empty input', () {
      expect(SaudiPhone.isValid(''), isFalse);
    });
  });
}
