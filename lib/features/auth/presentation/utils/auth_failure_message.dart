import '../../../../core/error/failures.dart';
import '../../../../core/utils/values/strings.dart';

extension AuthFailureMessage on Failure {
  /// Branches on the failure *type* (i.e. HTTP status), per the API guide:
  /// the wording of 401/429 bodies isn't meant for users. 403 bodies are —
  /// they carry the server's already-localized field message ("The phone has
  /// already been taken.").
  String get authMessage => switch (this) {
    UnauthorizedFailure() => Strings.authInvalidCredentials,
    TooManyRequestsFailure() => Strings.authTooManyAttempts,
    NetworkFailure(:final String? message) =>
      message ?? Strings.noInternetConnection,
    _ => message ?? Strings.somethingWentWrong,
  };
}
