import 'package:equatable/equatable.dart';

enum DiscountType { percent, amount }

/// A product a store sells.
class StoreItem extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;

  /// List price, before [discount].
  final double price;
  final double discount;
  final DiscountType discountType;
  final int? storeId;

  const StoreItem({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
    this.discount = 0,
    this.discountType = DiscountType.amount,
    this.storeId,
  });

  /// What the customer pays for one unit. Never negative, whatever the
  /// merchant typed as the discount.
  double get finalPrice {
    final double off = switch (discountType) {
      DiscountType.percent => price * discount / 100,
      DiscountType.amount => discount,
    };
    final double result = price - off;
    return result < 0 ? 0 : result;
  }

  bool get hasDiscount => finalPrice < price;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    imageUrl,
    price,
    discount,
    discountType,
    storeId,
  ];
}
