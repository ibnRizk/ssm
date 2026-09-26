import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/login_credentials.dart';
import '../entities/registration_details.dart';

/// Both calls persist the returned session token on success — the backend
/// signs a customer in immediately after sign-up, so there is no separate
/// login step.
abstract class AuthRepository {
  Future<Either<Failure, Unit>> login(LoginCredentials credentials);

  Future<Either<Failure, Unit>> register(RegistrationDetails details);

  /// Local only — the customer API has no logout endpoint. Discards the
  /// session token and any cached profile.
  Future<Either<Failure, Unit>> logout();
}
