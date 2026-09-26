import 'package:equatable/equatable.dart';

import 'failures.dart';

abstract class AppException extends Equatable implements Exception {
  abstract final String? message;

  const AppException();

  Failure toFailure();

  @override
  List<Object?> get props => [message];

  @override
  String toString() {
    return '$message';
  }
}

class ServerException extends AppException {
  @override
  final String? message;

  const ServerException({this.message});

  @override
  Failure toFailure() {
    return ServerFailure(message: message);
  }
}

class FetchDataException extends AppException {
  @override
  final String? message;

  const FetchDataException({this.message});

  @override
  Failure toFailure() {
    return FetchDataFailure(message: message);
  }
}

class UnauthorizedException extends AppException {
  @override
  final String? message;

  const UnauthorizedException({this.message});

  @override
  Failure toFailure() {
    return UnauthorizedFailure(message: message);
  }
}

/// HTTP 403. The backend's legacy controllers (auth, cart, order, address)
/// use it for validation errors and refusals, not only for permissions.
class ForbiddenException extends AppException {
  @override
  final String? message;

  /// `errors[0].code` — usually the offending field name (`phone`, `email`).
  final String? code;

  const ForbiddenException({this.message, this.code});

  @override
  Failure toFailure() {
    return ForbiddenFailure(message: message, code: code);
  }

  @override
  List<Object?> get props => [message, code];
}

/// HTTP 429 — the route is throttled.
class TooManyRequestsException extends AppException {
  @override
  final String? message;

  const TooManyRequestsException({this.message});

  @override
  Failure toFailure() {
    return TooManyRequestsFailure(message: message);
  }
}

class InternetConnectionException extends AppException {
  @override
  final String? message;

  const InternetConnectionException({this.message});

  @override
  Failure toFailure() {
    return NetworkFailure(message: message);
  }
}

class CacheException extends AppException {
  @override
  final String? message;

  const CacheException({this.message});

  @override
  Failure toFailure() {
    return CacheFailure(message: message);
  }
}

/// The device location is unavailable — see [LocationFailureReason].
class LocationException extends AppException {
  @override
  final String? message;

  final LocationFailureReason reason;

  const LocationException({required this.reason, this.message});

  @override
  Failure toFailure() {
    return LocationFailure(reason: reason, message: message);
  }

  @override
  List<Object?> get props => [message, reason];
}
