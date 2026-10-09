import '../../../../core/error/failures.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/c2c_parcel.dart';
import '../../domain/entities/c2c_parcel_draft.dart';
import '../../domain/entities/c2c_parcel_quote.dart';
import '../../domain/entities/c2c_parcel_status.dart';

extension C2cParcelStatusLabels on C2cParcelStatus {
  String get title => switch (this) {
    C2cParcelStatus.quoted => Strings.c2cStatusQuoted,
    C2cParcelStatus.pendingPayment => Strings.c2cStatusPendingPayment,
    C2cParcelStatus.pendingDispatch => Strings.c2cStatusPendingDispatch,
    C2cParcelStatus.dispatching => Strings.c2cStatusDispatching,
    C2cParcelStatus.assignmentFailed => Strings.c2cStatusAssignmentFailed,
    C2cParcelStatus.driverAssigned => Strings.c2cStatusDriverAssigned,
    C2cParcelStatus.driverAccepted => Strings.c2cStatusDriverAccepted,
    C2cParcelStatus.driverAtPickup => Strings.c2cStatusDriverAtPickup,
    C2cParcelStatus.pickedUp => Strings.c2cStatusPickedUp,
    C2cParcelStatus.outForDelivery => Strings.c2cStatusOutForDelivery,
    C2cParcelStatus.delivered => Strings.c2cStatusDelivered,
    C2cParcelStatus.failedDelivery => Strings.c2cStatusFailedDelivery,
    C2cParcelStatus.returningToSender => Strings.c2cStatusReturningToSender,
    C2cParcelStatus.returnedToSender => Strings.c2cStatusReturnedToSender,
    C2cParcelStatus.cancelled => Strings.c2cStatusCancelled,
    C2cParcelStatus.draft ||
    C2cParcelStatus.unknown => Strings.c2cStatusUnknown,
  };

  String get description => switch (this) {
    C2cParcelStatus.quoted => Strings.c2cStatusQuotedDesc,
    C2cParcelStatus.pendingPayment => Strings.c2cStatusPendingPaymentDesc,
    C2cParcelStatus.pendingDispatch => Strings.c2cStatusPendingDispatchDesc,
    C2cParcelStatus.dispatching => Strings.c2cStatusDispatchingDesc,
    C2cParcelStatus.assignmentFailed => Strings.c2cStatusAssignmentFailedDesc,
    C2cParcelStatus.driverAssigned => Strings.c2cStatusDriverAssignedDesc,
    C2cParcelStatus.driverAccepted => Strings.c2cStatusDriverAcceptedDesc,
    C2cParcelStatus.driverAtPickup => Strings.c2cStatusDriverAtPickupDesc,
    C2cParcelStatus.pickedUp => Strings.c2cStatusPickedUpDesc,
    C2cParcelStatus.outForDelivery => Strings.c2cStatusOutForDeliveryDesc,
    C2cParcelStatus.delivered => Strings.c2cStatusDeliveredDesc,
    C2cParcelStatus.failedDelivery => Strings.c2cStatusFailedDeliveryDesc,
    C2cParcelStatus.returningToSender => Strings.c2cStatusReturningToSenderDesc,
    C2cParcelStatus.returnedToSender => Strings.c2cStatusReturnedToSenderDesc,
    C2cParcelStatus.cancelled => Strings.c2cStatusCancelledDesc,
    C2cParcelStatus.draft ||
    C2cParcelStatus.unknown => Strings.c2cStatusUnknownDesc,
  };

  /// How the status reads at a glance — drives the chip and banner colour.
  C2cStatusTone get tone => switch (this) {
    C2cParcelStatus.delivered ||
    C2cParcelStatus.returnedToSender => C2cStatusTone.success,
    C2cParcelStatus.cancelled ||
    C2cParcelStatus.assignmentFailed ||
    C2cParcelStatus.failedDelivery => C2cStatusTone.problem,
    C2cParcelStatus.returningToSender => C2cStatusTone.warning,
    _ => C2cStatusTone.progress,
  };
}

enum C2cStatusTone { progress, success, warning, problem }

extension ParcelCategoryLabels on ParcelCategory {
  String get label => switch (this) {
    ParcelCategory.documents => Strings.sendParcelCategoryDocuments,
    ParcelCategory.small => Strings.sendParcelCategorySmall,
    ParcelCategory.medium => Strings.sendParcelCategoryMedium,
    ParcelCategory.large => Strings.sendParcelCategoryLarge,
    ParcelCategory.fragile => Strings.sendParcelCategoryFragile,
    ParcelCategory.other => Strings.sendParcelCategoryOther,
  };
}

extension C2cCancelReasonLabels on C2cCancelReason {
  String get label => switch (this) {
    C2cCancelReason.senderCancelled => Strings.c2cCancelReasonSenderCancelled,
    C2cCancelReason.wrongAddress => Strings.c2cCancelReasonWrongAddress,
    C2cCancelReason.other => Strings.c2cCancelReasonOther,
  };
}

extension C2cSupportReasonLabels on C2cSupportReason {
  String get label => switch (this) {
    C2cSupportReason.senderUnreachable =>
      Strings.c2cSupportReasonSenderUnreachable,
    C2cSupportReason.recipientUnreachable =>
      Strings.c2cSupportReasonRecipientUnreachable,
    C2cSupportReason.wrongAddress => Strings.c2cSupportReasonWrongAddress,
    C2cSupportReason.parcelDamaged => Strings.c2cSupportReasonParcelDamaged,
    C2cSupportReason.other => Strings.c2cSupportReasonOther,
  };
}

extension C2cPaymentMethodLabels on C2cPaymentMethod {
  String get label => switch (this) {
    C2cPaymentMethod.cashBySender => Strings.createParcelPaymentSender,
    C2cPaymentMethod.cashByRecipient => Strings.createParcelPaymentRecipient,
  };
}

extension C2cPhotoIssueLabels on C2cPhotoIssue {
  String get message => switch (this) {
    C2cPhotoIssue.tooLarge => Strings.createParcelPhotoTooLarge,
    C2cPhotoIssue.unsupportedType => Strings.createParcelPhotoUnsupported,
  };
}

extension C2cFailureMessage on Failure {
  /// Our own wording for the codes the customer can act on; the server's
  /// (already localized) message for everything else — pricing limits,
  /// prohibited content, a recipient who is the sender.
  String get c2cMessage {
    final String? code = switch (this) {
      ConflictFailure(:final String? code) => code,
      ServerFailure(:final String? code) => code,
      _ => null,
    };
    return switch (code) {
      C2cParcelErrorCode.staleVersion => Strings.c2cErrorStaleVersion,
      C2cParcelErrorCode.requestInProgress => Strings.c2cErrorRequestInProgress,
      C2cParcelErrorCode.idempotencyConflict =>
        Strings.c2cErrorIdempotencyConflict,
      C2cParcelErrorCode.cancelNotAllowedAfterPickup =>
        Strings.c2cErrorCancelAfterPickup,
      C2cParcelErrorCode.otpNotAvailable => Strings.c2cErrorOtpNotAvailable,
      _ => userMessage,
    };
  }
}

extension C2cParcelSummaryLabels on C2cParcelSummary {
  /// "To: Rami" for a sender, "From: Sara" for a recipient.
  String? get counterpartLabel {
    final String? name = counterpartName;
    if (name == null) return null;
    return viewerRole == C2cViewerRole.sender
        ? Strings.c2cParcelTo(name)
        : Strings.c2cParcelFrom(name);
  }
}
