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
