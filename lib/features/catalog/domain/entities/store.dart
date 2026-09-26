import 'package:equatable/equatable.dart';

/// A store (restaurant, pharmacy, …) in the customer's zone.
class Store extends Equatable {
  final int id;
  final String name;
  final String? logoUrl;
  final String? coverUrl;
  final String? address;

  /// 0 when the store has no ratings yet — see [hasRating].
  final double rating;
  final int ratingCount;

  /// Free text as the merchant entered it, e.g. `30-40 min`.
  final String? deliveryTime;

  /// The lowest delivery charge; the real fee depends on distance and is
  /// computed at checkout. Null when unknown.
  final double? minimumDeliveryFee;
  final bool freeDelivery;
  final double? minimumOrder;

  /// Null when the backend doesn't say — no open/closed badge is shown then.
  final bool? isOpen;

  /// Cuisine or category names, for the subtitle line.
  final List<String> tags;

  const Store({
    required this.id,
    required this.name,
    this.logoUrl,
    this.coverUrl,
    this.address,
    this.rating = 0,
    this.ratingCount = 0,
    this.deliveryTime,
    this.minimumDeliveryFee,
    this.freeDelivery = false,
    this.minimumOrder,
    this.isOpen,
    this.tags = const <String>[],
  });

  bool get hasRating => ratingCount > 0 && rating > 0;

  @override
  List<Object?> get props => [
    id,
    name,
    logoUrl,
    coverUrl,
    address,
    rating,
    ratingCount,
    deliveryTime,
    minimumDeliveryFee,
    freeDelivery,
    minimumOrder,
    isOpen,
    tags,
  ];
}
