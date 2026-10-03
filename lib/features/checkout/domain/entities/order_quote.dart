import 'package:equatable/equatable.dart';

/// Why delivery is free on a quote.
enum FreeDeliverySource { coupon, subscription, loyalty }

/// What to quote: the cart of [storeId], delivered [distanceKm] away.
class QuoteRequest extends Equatable {
  final int storeId;
  final double distanceKm;

  const QuoteRequest({required this.storeId, required this.distanceKm});

  @override
  List<Object?> get props => [storeId, distanceKm];
}

/// `POST /customer/order/quote` — the server's price breakdown for the
/// cart. The checkout shows these numbers as they are; nothing is added up
/// in the app.
class OrderQuote extends Equatable {
  final double subtotal;
  final double tax;
  final double couponDiscount;

  /// The delivery fee before a free delivery was applied.
  final double originalDeliveryCharge;

  /// What the customer pays for delivery — 0 when [freeDelivery].
  final double deliveryCharge;

  final bool freeDelivery;

  /// Why delivery is free; null when it isn't, or the reason is unknown.
  final FreeDeliverySource? freeDeliverySource;
  final double total;

  /// ISO code, e.g. `SAR`.
  final String currency;

  const OrderQuote({
    required this.subtotal,
    required this.deliveryCharge,
    required this.total,
    required this.currency,
    this.tax = 0,
    this.couponDiscount = 0,
    double? originalDeliveryCharge,
    this.freeDelivery = false,
    this.freeDeliverySource,
  }) : originalDeliveryCharge = originalDeliveryCharge ?? deliveryCharge;

  @override
  List<Object?> get props => [
    subtotal,
    tax,
    couponDiscount,
    originalDeliveryCharge,
    deliveryCharge,
    freeDelivery,
    freeDeliverySource,
    total,
    currency,
  ];
}
