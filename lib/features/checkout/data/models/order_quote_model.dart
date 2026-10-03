import '../../../../core/api/json_readers.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/order_quote.dart';

/// `{ subtotal, tax, discounts { coupon, delivery }, original_delivery_charge,
/// delivery_charge, free_delivery_applied, free_delivery_source, total,
/// currency }`, at the top level.
class OrderQuoteModel extends OrderQuote {
  const OrderQuoteModel({
    required super.subtotal,
    required super.deliveryCharge,
    required super.total,
    required super.currency,
    super.tax,
    super.couponDiscount,
    super.originalDeliveryCharge,
    super.freeDelivery,
    super.freeDeliverySource,
  });

  /// Throws [ServerException] without the amounts the checkout shows — a
  /// partial quote must never pass for the total.
  factory OrderQuoteModel.fromJson(dynamic json) {
    if (json is! Map) throw const ServerException();
    final double? subtotal = jsonDouble(json['subtotal']);
    final double? deliveryCharge = jsonDouble(json['delivery_charge']);
    final double? total = jsonDouble(json['total']);
    if (subtotal == null || deliveryCharge == null || total == null) {
      throw const ServerException();
    }
    final dynamic discounts = json['discounts'];
    final bool freeDelivery = jsonBool(json['free_delivery_applied']) ?? false;
    return OrderQuoteModel(
      subtotal: subtotal,
      deliveryCharge: deliveryCharge,
      total: total,
      currency: jsonString(json['currency']) ?? 'SAR',
      tax: jsonDouble(json['tax']) ?? 0,
      couponDiscount: discounts is Map
          ? jsonDouble(discounts['coupon']) ?? 0
          : 0,
      originalDeliveryCharge: jsonDouble(json['original_delivery_charge']),
      freeDelivery: freeDelivery,
      freeDeliverySource: freeDelivery
          ? _source(json['free_delivery_source'])
          : null,
    );
  }

  static FreeDeliverySource? _source(dynamic value) =>
      switch (jsonString(value)?.toLowerCase()) {
        'coupon' => FreeDeliverySource.coupon,
        'subscription' => FreeDeliverySource.subscription,
        'loyalty' => FreeDeliverySource.loyalty,
        _ => null,
      };
}
