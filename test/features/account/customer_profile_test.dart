import 'package:flutter_base/core/error/exceptions.dart';
import 'package:flutter_base/features/account/data/models/customer_profile_model.dart';
import 'package:flutter_base/features/account/domain/entities/customer_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomerProfileModel.fromJson', () {
    test('reads name, phone and created_at', () {
      final CustomerProfile profile =
          CustomerProfileModel.fromJson(<String, dynamic>{
            'id': 7,
            'name': 'Sara Customer',
            'phone': '+966512345678',
            'created_at': '2025-03-14T09:30:00.000000Z',
          });

      expect(profile.name, 'Sara Customer');
      expect(profile.phone, '+966512345678');
      expect(profile.memberSinceYear, 2025);
    });

    test('joins legacy f_name and l_name when name is absent', () {
      final CustomerProfile profile = CustomerProfileModel.fromJson(
        <String, dynamic>{
          'f_name': 'Sara',
          'l_name': 'Customer',
          'phone': '+966512345678',
        },
      );

      expect(profile.name, 'Sara Customer');
    });

    test('leaves memberSinceYear null for an unparseable date', () {
      final CustomerProfile profile = CustomerProfileModel.fromJson(
        <String, dynamic>{
          'name': 'Sara',
          'phone': '+966512345678',
          'created_at': 'yesterday',
        },
      );

      expect(profile.memberSinceYear, isNull);
    });

    test('throws ServerException when phone is missing', () {
      expect(
        () => CustomerProfileModel.fromJson(<String, dynamic>{'name': 'Sara'}),
        throwsA(isA<ServerException>()),
      );
    });

    test('throws ServerException when the body is not a map', () {
      expect(
        () => CustomerProfileModel.fromJson('<html></html>'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('CustomerProfile.initial', () {
    test('is the first letter of an Arabic name', () {
      expect(
        const CustomerProfile(name: 'عبدالعزيز محمد', phone: '').initial,
        'ع',
      );
    });

    test('is upper-cased for a Latin name', () {
      expect(const CustomerProfile(name: 'sara', phone: '').initial, 'S');
    });

    test('falls back to ? for a blank name', () {
      expect(const CustomerProfile(name: '  ', phone: '').initial, '?');
    });
  });
}
