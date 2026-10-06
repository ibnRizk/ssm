/// The canonical order status (`ssm_status`) the merchant and driver drive,
/// in the order it normally advances. [rejected] and [cancelled] are
/// terminal alternatives; [assignmentFailed] is a pause the store recovers
/// from by retrying dispatch.
enum OrderStatus {
  pendingMerchant,
  accepted,
  preparing,
  readyForPickup,
  dispatching,
  driverAssigned,
  driverAccepted,
  pickedUp,
  outForDelivery,
  delivered,
  rejected,
  cancelled,
  assignmentFailed;

  /// The status to show. [canonical] (`ssm_status`) wins once the order is
  /// past pending. Until then it's null or [pendingMerchant], and a
  /// customer cancellation shows only in the legacy `order_status` — the
  /// backend records no canonical entry for it. Anything else reads as
  /// pending.
  static OrderStatus resolve(OrderStatus? canonical, String? legacyStatus) {
    if (canonical != null && canonical != pendingMerchant) return canonical;
    return switch (legacyStatus?.toLowerCase()) {
      'canceled' || 'cancelled' || 'failed' => cancelled,
      'delivered' => delivered,
      _ => pendingMerchant,
    };
  }

  /// Not yet accepted by the merchant — the customer may still cancel.
  bool get canBeCancelled => this == pendingMerchant;

  /// Where this status sits on the customer's timeline. Null for the
  /// terminal failures, which leave the timeline.
  OrderStage? get stage => switch (this) {
    pendingMerchant => OrderStage.placed,
    accepted || preparing || readyForPickup => OrderStage.preparing,
    // No courier accepted yet: the store can retry dispatch, so the order
    // is still waiting for one, not over.
    dispatching ||
    driverAssigned ||
    driverAccepted ||
    assignmentFailed => OrderStage.courierToStore,
    pickedUp || outForDelivery => OrderStage.courierToCustomer,
    delivered => OrderStage.delivered,
    rejected || cancelled => null,
  };

  bool get isFailed => stage == null;

  /// Nothing changes after these — polling stops.
  bool get isFinal => this == delivered || isFailed;

  /// The courier is on the way and completes the delivery with the
  /// customer's delivery OTP.
  bool get needsDeliveryOtp => this == outForDelivery;
}

/// The customer-facing steps of an order, in order.
enum OrderStage {
  placed,
  preparing,
  courierToStore,
  courierToCustomer,
  delivered,
}
