import '../../../../core/error/failures.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/address.dart';
import '../../domain/repos/address_repository.dart';

extension AddressFailureMessage on Failure {
  /// Problems with the picked location — shown inline under the location
  /// row, where the customer can fix them, instead of in a snack bar.
  bool get isLocationProblem =>
      this is LocationFailure ||
      (this is ForbiddenFailure &&
          (this as ForbiddenFailure).code == outOfCoverageCode);

  String get addressMessage => switch (this) {
    ForbiddenFailure(code: outOfCoverageCode) => Strings.addressOutOfCoverage,
    LocationFailure(:final reason) => switch (reason) {
      LocationFailureReason.serviceDisabled => Strings.locationServiceDisabled,
      LocationFailureReason.permissionDenied =>
        Strings.locationPermissionDenied,
      LocationFailureReason.deniedForever =>
        Strings.locationPermissionDeniedForever,
      LocationFailureReason.unavailable => Strings.locationUnavailable,
    },
    _ => userMessage,
  };
}

extension AddressTypeLabel on AddressType {
  String get label => switch (this) {
    AddressType.home => Strings.addressTypeHome,
    AddressType.office => Strings.addressTypeOffice,
    AddressType.other => Strings.addressTypeOther,
  };
}
