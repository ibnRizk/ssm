import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/login_credentials.dart';
import '../../domain/entities/registration_details.dart';
import '../../domain/repos/auth_repository.dart';
import '../../domain/utils/saudi_phone.dart';
import 'auth_state.dart';

/// Screen-scoped (one instance per Login/Register route). Takes raw form
/// input and normalises it into domain values before calling the repository.
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;

  static final RegExp _whitespace = RegExp(r'\s+');

  AuthCubit({required this.repository}) : super(const AuthInitial());

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
        name: name.trim().replaceAll(_whitespace, ' '),
        phone: SaudiPhone.toE164(phone),
        email: email.trim(),
        password: password,
      ),
    ),
  );

  /// Purely local — the customer API has no logout endpoint.
  Future<void> logout() =>
      _submit(repository.logout, onSuccess: const AuthUnauthenticated());

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
