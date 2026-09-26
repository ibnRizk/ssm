import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// The session token is stored — the customer is signed in.
final class AuthSuccess extends AuthState {
  const AuthSuccess();
}

/// The session was discarded locally — the customer is signed out.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Carries the typed [Failure], not a string, so the UI decides the wording
/// (and the cubit stays free of localization).
final class AuthError extends AuthState {
  final Failure failure;

  const AuthError(this.failure);

  @override
  List<Object?> get props => [failure];
}
