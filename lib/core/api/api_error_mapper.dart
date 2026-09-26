import 'package:dio/dio.dart';

import '../base_classes/api_error.dart';
import '../error/exceptions.dart';
import '../utils/values/strings.dart';
import 'status_code.dart';

/// Maps a failed Dio call to the app's typed exceptions.
///
/// Status codes follow the backend contract in
/// `docs/SSM_CUSTOMER_API_GUIDE.md`: 401 bad credentials or token, 403 legacy
/// validation/refusal (`{"errors":[{"code","message"}]}`), 422 SSM
/// validation, 429 throttling.
///
/// Messages are `null` when the body carries none — the presentation layer
/// picks a localized fallback, instead of a raw HTML page or JSON dump
/// reaching the user.
AppException mapDioException(DioException error) {
  final dynamic data = error.response?.data;

  switch (error.response?.statusCode) {
    case StatusCode.unauthorized:
      return UnauthorizedException(message: apiErrorMessage(data));
    case StatusCode.forbidden:
      return ForbiddenException(
        message: apiErrorMessage(data),
        code: apiErrorCode(data),
      );
    case StatusCode.tooManyRequests:
      return TooManyRequestsException(message: apiErrorMessage(data));
    case StatusCode.unProcessableContent:
      if (data is Map<String, dynamic>) {
        return ServerException(
          message: APIError.fromJson(data).getFirstError(),
        );
      }
      return ServerException(message: apiErrorMessage(data));
  }

  switch (error.type) {
    case DioExceptionType.connectionError:
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return InternetConnectionException(message: Strings.noInternetConnection);
    case DioExceptionType.cancel:
      return ServerException(message: Strings.requestCancelled);
    default:
      return ServerException(message: apiErrorMessage(data));
  }
}

/// First human-readable message in an error body, in the backend's order of
/// precedence: `errors[0].message`, then the first entry of an
/// `errors: {field: [...]}` map, then `message`.
String? apiErrorMessage(dynamic data) {
  if (data is! Map) return null;

  final dynamic errors = data['errors'];
  if (errors is List && errors.isNotEmpty) {
    final dynamic first = errors.first;
    if (first is Map) {
      final String? message = _nonEmptyString(first['message']);
      if (message != null) return message;
    }
  }
  if (errors is Map && errors.isNotEmpty) {
    final dynamic first = errors.values.first;
    if (first is List && first.isNotEmpty) return _nonEmptyString(first.first);
  }
  return _nonEmptyString(data['message']);
}

/// `errors[0].code` — the backend's stable identifier to branch on
/// (`auth-001`, `phone`, `coordinates`, …). The message wording may change.
String? apiErrorCode(dynamic data) {
  if (data is! Map) return null;
  final dynamic errors = data['errors'];
  if (errors is List && errors.isNotEmpty && errors.first is Map) {
    return _nonEmptyString((errors.first as Map)['code']);
  }
  return null;
}

String? _nonEmptyString(dynamic value) =>
    value is String && value.trim().isNotEmpty ? value : null;
