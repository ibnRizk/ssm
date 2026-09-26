import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/pharmacy_request.dart';
import '../../domain/entities/prescription_image.dart';
import '../cubit/pharmacy_order_state.dart';

extension PharmacyNoticeMessage on PharmacyNotice {
  String get message => switch (this) {
    PharmacyIncomplete(:final issue) => switch (issue) {
      PharmacyRequestIssue.noPharmacy => Strings.pharmacyIssueNoPharmacy,
      PharmacyRequestIssue.noAddress => Strings.pharmacyIssueNoAddress,
      PharmacyRequestIssue.noContent => Strings.pharmacyIssueNoContent,
    },
    PrescriptionRejected(:final issue) => switch (issue) {
      PrescriptionImageIssue.tooLarge => Strings.pharmacyImageTooLarge,
      PrescriptionImageIssue.unsupportedType =>
        Strings.pharmacyImageUnsupported,
    },
    // 422s (e.g. "not a pharmacy") carry the backend's localized message.
    PharmacyActionFailed(:final failure) => failure.userMessage,
  };
}
