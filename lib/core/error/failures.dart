import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  abstract final String? message;

  const Failure();

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  @override
  final String? message;

  const ServerFailure({this.message});
}

class UnauthorizedFailure extends Failure {
  @override
  final String? message;

  const UnauthorizedFailure({this.message});
}

/// See [ForbiddenException] — validation errors and refusals, not only
/// permissions.
class ForbiddenFailure extends Failure {
  @override
  final String? message;

  final String? code;

  const ForbiddenFailure({this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

class TooManyRequestsFailure extends Failure {
  @override
  final String? message;

  const TooManyRequestsFailure({this.message});
}

class CacheFailure extends Failure {
  @override
  final String? message;

  const CacheFailure({this.message});
}

class NetworkFailure extends Failure {
  @override
  final String? message;

  const NetworkFailure({this.message});
}

class FetchDataFailure extends Failure {
  @override
  final String? message;

  const FetchDataFailure({this.message});
}

/// Why the device couldn't produce a position — each needs a different
/// prompt (turn on GPS vs. grant access vs. open settings vs. try again).
enum LocationFailureReason {
  serviceDisabled,
  permissionDenied,
  deniedForever,

  /// No fix in time (indoors, weak signal).
  unavailable,
}

class LocationFailure extends Failure {
  @override
  final String? message;

  final LocationFailureReason reason;

  const LocationFailure({required this.reason, this.message});

  @override
  List<Object?> get props => [message, reason];
}
