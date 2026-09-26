import 'package:ssm/core/error/exceptions.dart';
import 'package:ssm/features/auth/data/models/requests/login_request.dart';
import 'package:ssm/features/auth/data/models/requests/register_request.dart';
import 'package:ssm/features/auth/data/models/responses/auth_token_response.dart';
import 'package:ssm/features/auth/domain/entities/login_credentials.dart';
import 'package:ssm/features/auth/domain/entities/registration_details.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginRequest', () {
    test('serialises to the manual phone login payload', () {
      final LoginRequest request = LoginRequest.fromCredentials(
        const LoginCredentials(phone: '+966512345678', password: 'secret123'),
      );

      expect(request.toJson(), <String, dynamic>{
        'login_type': 'manual',
        'email_or_phone': '+966512345678',
        'field_type': 'phone',
        'password': 'secret123',
      });
    });
  });

  group('RegisterRequest', () {
    test('serialises to exactly name, phone, email, password', () {
      final RegisterRequest request = RegisterRequest.fromDetails(
        const RegistrationDetails(
          name: 'Sara Customer',
          phone: '+966512345678',
          email: 'sara@ssm.test',
          password: 'secret123',
        ),
      );

      expect(request.toJson(), <String, dynamic>{
        'name': 'Sara Customer',
        'phone': '+966512345678',
        'email': 'sara@ssm.test',
        'password': 'secret123',
      });
    });
  });

  group('AuthTokenResponse.fromJson', () {
    test('reads the token', () {
      expect(
        AuthTokenResponse.fromJson(<String, dynamic>{'token': 'abc'}).token,
        'abc',
      );
    });

    test('throws ServerException when the token is missing', () {
      expect(
        () => AuthTokenResponse.fromJson(<String, dynamic>{}),
        throwsA(isA<ServerException>()),
      );
    });

    test('throws ServerException when the token is blank', () {
      expect(
        () => AuthTokenResponse.fromJson(<String, dynamic>{'token': '  '}),
        throwsA(isA<ServerException>()),
      );
    });

    test('throws ServerException when the body is not a map', () {
      expect(
        () => AuthTokenResponse.fromJson('<html></html>'),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
