import '../error/failures.dart';
import 'values/strings.dart';

extension FailureMessage on Failure {
  /// Default user-facing wording for a failure. 403/422 bodies carry the
  /// server's already-localized message ("The email has already been
  /// taken."), so it's shown as-is; otherwise a localized fallback. Features
  /// with special cases (e.g. an address outside the coverage zone) branch
  /// on the failure first and fall back to this.
  String get userMessage => switch (this) {
    NetworkFailure(:final String? message) =>
      message ?? Strings.noInternetConnection,
    LocationFailure(:final reason) => switch (reason) {
      LocationFailureReason.serviceDisabled => Strings.locationServiceDisabled,
      LocationFailureReason.permissionDenied =>
        Strings.locationPermissionDenied,
      LocationFailureReason.deniedForever =>
        Strings.locationPermissionDeniedForever,
      LocationFailureReason.unavailable => Strings.locationUnavailable,
    },
    _ => message ?? Strings.somethingWentWrong,
  };
}
