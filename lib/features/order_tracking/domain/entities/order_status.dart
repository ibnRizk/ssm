/// The canonical order status (`ssm_status`) the merchant and driver drive,
/// in the order it normally advances; the last three are terminal
/// alternatives.
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

  /// The status to show. [canonical] (`ssm_status`) wins; it's null until
  /// the merchant first acts, and then the legacy `order_status` still
  /// knows about a customer cancellation. Anything else reads as pending.
  static OrderStatus resolve(OrderStatus? canonical, String? legacyStatus) =>
      canonical ??
      switch (legacyStatus?.toLowerCase()) {
        'canceled' || 'cancelled' || 'failed' => cancelled,
        'delivered' => delivered,
        _ => pendingMerchant,
      };

  /// Where this status sits on the customer's timeline. Null for the
  /// terminal failures, which leave the timeline.
  OrderStage? get stage => switch (this) {
    pendingMerchant => OrderStage.placed,
    accepted || preparing || readyForPickup => OrderStage.preparing,
    dispatching ||
    driverAssigned ||
    driverAccepted => OrderStage.courierToStore,
    pickedUp || outForDelivery => OrderStage.courierToCustomer,
    delivered => OrderStage.delivered,
    rejected || cancelled || assignmentFailed => null,
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
