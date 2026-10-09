import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/push/push_repository.dart';
import '../../../../core/utils/saudi_phone.dart';
import '../../../../core/utils/string_extension.dart';
import '../../domain/entities/login_credentials.dart';
import '../../domain/entities/registration_details.dart';
import '../../domain/repos/auth_repository.dart';
import 'auth_state.dart';

/// Screen-scoped (one instance per Login/Register route). Takes raw form
/// input and normalises it into domain values before calling the repository.
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;

  /// Unregisters this device from push on [logout]. Optional so the sign-in
  /// screens, which never log out, don't need it.
  final PushRepository? push;

  /// How long logout waits for the push unregistration before signing out
  /// anyway — an offline customer must still be able to log out.
  final Duration unregisterTimeout;

  AuthCubit({
    required this.repository,
    this.push,
    this.unregisterTimeout = const Duration(seconds: 5),
  }) : super(const AuthInitial());

  Future<void> login({required String phone, required String password}) =>
      _submit(
        () => repository.login(
          LoginCredentials(phone: SaudiPhone.toE164(phone), password: password),
        ),
      );

  Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) => _submit(
    () => repository.register(
      RegistrationDetails(
        name: name.collapseWhitespace(),
        phone: SaudiPhone.toE164(phone),
        email: email.trim(),
        password: password,
      ),
    ),
  );

  /// The customer API has no logout endpoint. Its contract instead: stop
  /// pushes with `remove-fcm-token` — while the bearer token still works —
  /// then drop the session locally. The first step is best-effort; a
  /// failure or timeout there never blocks signing out.
  Future<void> logout() => _submit(() async {
    try {
      await push?.unregisterDevice().timeout(unregisterTimeout);
    } on TimeoutException {
      // Offline or slow: the next sign-in on any device re-registers it.
    }
    return repository.logout();
  }, onSuccess: const AuthUnauthenticated());

  Future<void> _submit(
    Future<Either<Failure, Unit>> Function() request, {
    AuthState onSuccess = const AuthSuccess(),
  }) async {
    // Auth routes are throttled (10/min) — never fire a second request
    // while one is in flight.
    if (state is AuthLoading) return;
    emit(const AuthLoading());
    final Either<Failure, Unit> result = await request();
    if (isClosed) return;
    result.fold(
      (Failure failure) => emit(AuthError(failure)),
      (_) => emit(onSuccess),
    );
  }
}
