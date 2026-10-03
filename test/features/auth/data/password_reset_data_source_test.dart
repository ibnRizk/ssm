import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/api/api_endpoints.dart';
import 'package:ssm/core/error/exceptions.dart';
import 'package:ssm/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ssm/features/auth/data/models/requests/password_reset_request.dart';

import '../../../helpers/fake_dio_consumer.dart';

const PasswordResetRequest _request = PasswordResetRequest(
  phone: '+966512345678',
  code: '1234',
  password: 'newSecret1',
);

void main() {
  late FakeDioConsumer consumer;
  late AuthRemoteDataSourceImpl dataSource;

  setUp(() {
    consumer = FakeDioConsumer(
      response: <String, dynamic>{'message': 'OTP sent successfully'},
    );
    dataSource = AuthRemoteDataSourceImpl(consumer: consumer);
  });

  test('requesting a code POSTs to forgot-password', () async {
    await dataSource.requestPasswordReset(_request);

    expect(consumer.lastVerb, 'POST');
    expect(consumer.lastPath, ApiEndpoints.forgotPassword);
  });

  test('verifying POSTs to verify-token', () async {
    await dataSource.verifyPasswordResetCode(_request);

    expect(consumer.lastVerb, 'POST');
    expect(consumer.lastPath, ApiEndpoints.verifyResetToken);
  });

  test('resetting PUTs to reset-password', () async {
    await dataSource.resetPassword(_request);

    expect(consumer.lastVerb, 'PUT');
    expect(consumer.lastPath, ApiEndpoints.resetPassword);
  });

  test('an errors body under a success status is a refusal', () {
    consumer.response = <String, dynamic>{
      'errors': <dynamic>[
        <String, dynamic>{'code': 'reset_token', 'message': 'Invalid OTP'},
      ],
    };

    expect(
      dataSource.verifyPasswordResetCode(_request),
      throwsA(
        const ForbiddenException(message: 'Invalid OTP', code: 'reset_token'),
      ),
    );
  });
}
