/// The canonical status of a door-to-door parcel, as `status` on the wire.
enum C2cParcelStatus {
  draft('draft'),
  quoted('quoted'),
  pendingPayment('pending_payment'),
  pendingDispatch('pending_dispatch'),
  dispatching('dispatching'),
  assignmentFailed('assignment_failed'),
  driverAssigned('driver_assigned'),
  driverAccepted('driver_accepted'),
  driverAtPickup('driver_at_pickup'),
  pickedUp('picked_up'),
  outForDelivery('out_for_delivery'),
  delivered('delivered'),
  failedDelivery('failed_delivery'),
  returningToSender('returning_to_sender'),
  returnedToSender('returned_to_sender'),
  cancelled('cancelled'),

  /// A status this app version doesn't know yet. Treated as in progress.
  unknown('');

  final String wire;

  const C2cParcelStatus(this.wire);

  static C2cParcelStatus fromWire(String? value) {
    for (final C2cParcelStatus status in values) {
      if (status != unknown && status.wire == value) return status;
    }
    return unknown;
  }

  /// Nothing moves after these.
  bool get isTerminal =>
      this == delivered || this == returnedToSender || this == cancelled;

  /// Before the driver has the parcel — the sender may still cancel.
  bool get isBeforePickup => switch (this) {
    draft ||
    quoted ||
    pendingPayment ||
    pendingDispatch ||
    dispatching ||
    assignmentFailed ||
    driverAssigned ||
    driverAccepted ||
    driverAtPickup => true,
    _ => false,
  };

  /// Still looking for a driver.
  bool get isSearchingForDriver =>
      this == pendingDispatch || this == dispatching || this == driverAssigned;

  /// A delivery code can be asked for (by the recipient or the sender).
  bool get allowsDeliveryOtp =>
      this == outForDelivery || this == failedDelivery;

  /// The sender can ask for the code that proves the parcel came back.
  bool get allowsReturnOtp => this == returningToSender;

  /// The parcel left the delivery path: it's being, or was, sent back.
  bool get isReturnPath =>
      this == returningToSender || this == returnedToSender;

  /// Whether [role] may follow the driver live now — the stages the server
  /// authorizes the tracking channel for: the sender from acceptance until
  /// the return ends, the recipient only while the parcel is on its way.
  bool showsDriverTo(C2cViewerRole role) => switch (role) {
    C2cViewerRole.sender => switch (this) {
      driverAccepted ||
      driverAtPickup ||
      pickedUp ||
      outForDelivery ||
      failedDelivery ||
      returningToSender => true,
      _ => false,
    },
    C2cViewerRole.recipient =>
      this == pickedUp || this == outForDelivery || this == failedDelivery,
  };
}

/// Who is looking at the parcel. The server shapes every response by it.
enum C2cViewerRole {
  sender,
  recipient;

  /// A missing or unknown role reads as [recipient], the one with fewer
  /// rights, so a malformed response never unlocks sender-only details or
  /// commands.
  static C2cViewerRole fromWire(String? value) => switch (value) {
    'sender' => sender,
    _ => recipient,
  };
}

/// Why a parcel was cancelled, sent as `reason_code`.
enum C2cCancelReason {
  senderCancelled('sender_cancelled'),
  wrongAddress('wrong_address'),
  other('other');

  final String wire;

  const C2cCancelReason(this.wire);
}

/// Why the customer opens a support case, sent as `reason_code`.
enum C2cSupportReason {
  senderUnreachable('sender_unreachable'),
  recipientUnreachable('recipient_unreachable'),
  wrongAddress('wrong_address'),
  parcelDamaged('parcel_damaged'),
  other('other');

  final String wire;

  const C2cSupportReason(this.wire);
}

/// Who pays the driver in cash, sent as `payment_method`.
enum C2cPaymentMethod {
  cashBySender('cash_by_sender'),
  cashByRecipient('cash_by_recipient');

  final String wire;

  const C2cPaymentMethod(this.wire);

  static C2cPaymentMethod fromWire(String? value) =>
      value == cashByRecipient.wire ? cashByRecipient : cashBySender;
}

/// `errors[0].code` values the parcel endpoints answer with — branch on
/// these, never on the message wording.
abstract final class C2cParcelErrorCode {
  /// 409: the parcel moved on since `expected_version`; refresh and decide
  /// again.
  static const String staleVersion = 'stale_version';

  /// 409 on create: the quoted price no longer holds.
  static const String priceChanged = 'price_changed';
  static const String quoteExpired = 'quote_expired';

  /// 409: the same Idempotency-Key with a different body.
  static const String idempotencyConflict = 'idempotency_conflict';

  /// 409: the first request with this key is still running — its outcome
  /// is unknown; retry later with the same key.
  static const String requestInProgress = 'request_in_progress';

  /// 422: the command isn't allowed in the current status.
  static const String invalidTransition = 'invalid_transition';
  static const String cancelNotAllowedAfterPickup =
      'cancel_not_allowed_after_pickup';
  static const String cancelNotAllowed = 'cancel_not_allowed';

  /// 422 pricing limits.
  static const String pickupOutOfServiceArea = 'pickup_out_of_service_area';
  static const String dropoffOutOfServiceArea = 'dropoff_out_of_service_area';
  static const String distanceTooLong = 'distance_too_long';
  static const String weightTooHeavy = 'weight_too_heavy';

  /// 422 on create.
  static const String prohibitedContent = 'prohibited_content';
  static const String recipientIsSender = 'recipient_is_sender';

  /// 422: no code can be issued in the current status.
  static const String otpNotAvailable = 'otp_not_available';
}
