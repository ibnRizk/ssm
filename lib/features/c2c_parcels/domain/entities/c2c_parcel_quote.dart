import 'package:equatable/equatable.dart';

import '../../../../core/location/geo_point.dart';

/// What kind of parcel it is, sent as its [name]. The server prices each
/// category differently.
enum ParcelCategory { documents, small, medium, large, fragile, other }

/// What the customer wants priced: both ends and the parcel itself.
class C2cQuoteRequest extends Equatable {
  final GeoPoint sender;
  final GeoPoint recipient;
  final ParcelCategory category;
  final double weightKg;
  final bool isFragile;

  /// What's inside, e.g. "Gift Box". Null when the customer left it blank.
  final String? title;

  const C2cQuoteRequest({
    required this.sender,
    required this.recipient,
    required this.category,
    required this.weightKg,
    required this.isFragile,
    this.title,
  });

  @override
  List<Object?> get props => [
    sender,
    recipient,
    category,
    weightKg,
    isFragile,
    title,
  ];
}

/// The parcel plan the server applied to a quote. Only present when the
/// customer has an active plan and the parcel is within its zone, distance
/// and weight limits.
class AppliedParcelSubscription extends Equatable {
  /// Deliveries left on the plan, as the server reports it. Null when the
  /// response omits it — the discount still applies.
  final int? remainingDeliveries;

  /// Null when the response omits them.
  final int? subscriptionId;
  final String? planName;

  const AppliedParcelSubscription({
    this.remainingDeliveries,
    this.subscriptionId,
    this.planName,
  });

  @override
  List<Object?> get props => [remainingDeliveries, subscriptionId, planName];
}

/// A priced door-to-door parcel. The fees are the server's — never
/// recomputed here — so [totalFee] is shown as sent.
class C2cParcelQuote extends Equatable {
  /// Holds this price when the parcel is created. Null if the response
  /// lacks it — the quote can still be shown, but not booked.
  final String? quoteToken;

  /// The price before any plan discount.
  final double baseTotalFee;

  /// What the applied plan takes off; 0 without one.
  final double subscriptionDiscount;

  /// What the customer pays.
  final double totalFee;

  /// ISO 4217 code as sent by the backend, e.g. `SAR`.
  final String currency;

  final double? distanceKm;
  final int? estimatedDeliveryMinutes;

  /// When [quoteToken] stops holding the price (15 minutes after quoting).
  final DateTime? expiresAt;

  /// Null when no plan applies: no active plan, or the parcel is outside
  /// its zone, distance or weight limits.
  final AppliedParcelSubscription? appliedSubscription;

  const C2cParcelQuote({
    this.quoteToken,
    required this.baseTotalFee,
    required this.subscriptionDiscount,
    required this.totalFee,
    required this.currency,
    this.distanceKm,
    this.estimatedDeliveryMinutes,
    this.expiresAt,
    this.appliedSubscription,
  });

  /// Whether the price is still held at [now]. A quote without an expiry
  /// is trusted until the server says otherwise.
  bool isValidAt(DateTime now) {
    final DateTime? expiresAt = this.expiresAt;
    return quoteToken != null && (expiresAt == null || now.isBefore(expiresAt));
  }

  @override
  List<Object?> get props => [
    quoteToken,
    baseTotalFee,
    subscriptionDiscount,
    totalFee,
    currency,
    distanceKm,
    estimatedDeliveryMinutes,
    expiresAt,
    appliedSubscription,
  ];
}
