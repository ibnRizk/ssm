import 'package:dio/dio.dart';
import 'package:ssm/core/api/api_error_mapper.dart';
import 'package:ssm/core/error/exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _badResponse(int status, dynamic data) {
  final RequestOptions options = RequestOptions(path: '/api/v1/auth/login');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: options,
      statusCode: status,
      data: data,
    ),
  );
}

void main() {
  group('mapDioException — error codes', () {
    test('422 keeps the errors[0] code next to the message', () {
      final AppException result = mapDioException(
        _badResponse(422, <String, dynamic>{
          'message':
              'The parcel cannot move from driver_accepted to picked_up.',
          'errors': <Map<String, String>>[
            <String, String>{
              'code': 'invalid_transition',
              'message':
                  'The parcel cannot move from driver_accepted to picked_up.',
            },
          ],
          'current_status': 'driver_accepted',
          'current_version': 5,
        }),
      );

      expect(
        result,
        const ServerException(
          message: 'The parcel cannot move from driver_accepted to picked_up.',
          code: 'invalid_transition',
        ),
      );
    });

    test('a field-validation 422 has no code', () {
      final AppException result = mapDioException(
        _badResponse(422, <String, dynamic>{
          'message': 'The title field is required.',
          'errors': <String, dynamic>{
            'title': <String>['The title field is required.'],
          },
        }),
      );

      expect(result, isA<ServerException>());
      expect((result as ServerException).code, isNull);
    });

    test('428 idempotency_key_required keeps its code', () {
      final AppException result = mapDioException(
        _badResponse(428, <String, dynamic>{
          'errors': <Map<String, String>>[
            <String, String>{
              'code': 'idempotency_key_required',
              'message': 'Idempotency-Key header is required.',
            },
          ],
        }),
      );

      expect(
        result,
        const ServerException(
          message: 'Idempotency-Key header is required.',
          code: 'idempotency_key_required',
        ),
      );
    });
  });

  group('mapDioException', () {
    test('404 maps to NotFoundException with the body message', () {
      final AppException result = mapDioException(
        _badResponse(404, <String, dynamic>{'message': 'Cart item not found'}),
      );

      expect(result, const NotFoundException(message: 'Cart item not found'));
    });

    test('401 wrong credentials maps to UnauthorizedException', () {
      final AppException result = mapDioException(
        _badResponse(401, <String, dynamic>{
          'errors': <Map<String, String>>[
            <String, String>{'code': 'auth-001', 'message': 'Unauthorized.'},
          ],
        }),
      );

      expect(result, const UnauthorizedException(message: 'Unauthorized.'));
    });

    // Regression: 403 used to become UnauthorizedException, but this backend
    // uses 403 for validation errors such as a duplicate phone.
    test(
      '403 maps to ForbiddenException carrying errors[0] code and message',
      () {
        final AppException result = mapDioException(
          _badResponse(403, <String, dynamic>{
            'errors': <Map<String, String>>[
              <String, String>{
                'code': 'phone',
                'message': 'The phone has already been taken.',
              },
            ],
          }),
        );

        expect(
          result,
          const ForbiddenException(
            message: 'The phone has already been taken.',
            code: 'phone',
          ),
        );
      },
    );

    test('409 maps to ConflictException carrying the error code', () {
      final AppException result = mapDioException(
        _badResponse(409, <String, dynamic>{
          'errors': <Map<String, String>>[
            <String, String>{
              'code': 'otp-not-available',
              'message': 'The order is not out for delivery.',
            },
          ],
        }),
      );

      expect(
        result,
        const ConflictException(
          message: 'The order is not out for delivery.',
          code: 'otp-not-available',
        ),
      );
    });

    test('429 maps to TooManyRequestsException', () {
      final AppException result = mapDioException(
        _badResponse(429, <String, dynamic>{'message': 'Too Many Attempts.'}),
      );

      expect(
        result,
        const TooManyRequestsException(message: 'Too Many Attempts.'),
      );
    });

    test('non-JSON error body yields a null message, not the raw body', () {
      final AppException result = mapDioException(
        _badResponse(500, '<html>Server Error</html>'),
      );

      expect(result, const ServerException());
    });
  });

  group('apiErrorMessage', () {
    test('prefers errors[0].message over message', () {
      expect(
        apiErrorMessage(<String, dynamic>{
          'message': 'outer',
          'errors': <Map<String, String>>[
            <String, String>{'code': 'email', 'message': 'inner'},
          ],
        }),
        'inner',
      );
    });

    test('reads the first entry of an errors map', () {
      expect(
        apiErrorMessage(<String, dynamic>{
          'errors': <String, List<String>>{
            'per_page': <String>['Must be at most 50.'],
          },
        }),
        'Must be at most 50.',
      );
    });

    test('falls back to message', () {
      expect(
        apiErrorMessage(<String, dynamic>{'message': 'Unauthenticated.'}),
        'Unauthenticated.',
      );
    });

    test('returns null for an empty body', () {
      expect(apiErrorMessage(<String, dynamic>{}), isNull);
    });
  });

  group('apiErrorCode', () {
    test('reads errors[0].code', () {
      expect(
        apiErrorCode(<String, dynamic>{
          'errors': <Map<String, String>>[
            <String, String>{'code': 'auth-001', 'message': 'x'},
          ],
        }),
        'auth-001',
      );
    });

    test('returns null when errors is absent', () {
      expect(apiErrorCode(<String, dynamic>{'message': 'x'}), isNull);
    });
  });
}
