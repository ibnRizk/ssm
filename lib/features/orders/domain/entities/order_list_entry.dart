import 'package:equatable/equatable.dart';

/// Where an order stands, as the order lists show it — read from the
/// legacy `order_status` those endpoints return.
enum OrderListStatus {
  pending,
  preparing,
  awaitingCourier,
  onTheWay,
  delivered,
  cancelled,
  refunded;

  /// Anything unknown reads as pending.
  static OrderListStatus fromLegacy(String? value) =>
      switch (value?.toLowerCase()) {
        'accepted' || 'confirmed' || 'processing' => preparing,
        'handover' => awaitingCourier,
        'picked_up' => onTheWay,
        // A withdrawn refund request leaves the order delivered.
        'delivered' || 'refund_request_canceled' => delivered,
        'canceled' || 'cancelled' || 'failed' => cancelled,
        'refund_requested' || 'refunded' => refunded,
        _ => pending,
      };
}

/// What the store sells, to pick the card's icon.
enum OrderStoreKind { food, grocery, pharmacy, other }

/// One product of an order, for the card's summary line.
class OrderItemSummary extends Equatable {
  final String name;
  final int quantity;

  const OrderItemSummary({required this.name, required this.quantity});

  @override
  List<Object?> get props => [name, quantity];
}

/// One order in `order/running-orders` or `order/list`.
class OrderListEntry extends Equatable {
  final int id;
  final OrderListStatus status;

  /// The order total, delivery included.
  final double? orderAmount;
  final DateTime? createdAt;
  final int? storeId;
  final String? storeName;
  final OrderStoreKind storeKind;

  /// The products, when the list carries them; otherwise [itemCount] is
  /// all that's known.
  final List<OrderItemSummary> items;
  final int? itemCount;

  const OrderListEntry({
    required this.id,
    required this.status,
    this.orderAmount,
    this.createdAt,
    this.storeId,
    this.storeName,
    this.storeKind = OrderStoreKind.other,
    this.items = const <OrderItemSummary>[],
    this.itemCount,
  });

  @override
  List<Object?> get props => [
    id,
    status,
    orderAmount,
    createdAt,
    storeId,
    storeName,
    storeKind,
    items,
    itemCount,
  ];
}

/// One line of a past order (`order/details`), to put back in the cart.
class OrderedItem extends Equatable {
  /// Null for a line that isn't a plain store item (e.g. a campaign item),
  /// which can't be re-added.
  final int? itemId;
  final int? storeId;
  final int quantity;

  /// What one unit cost then; the server reprices when the order is placed.
  final double unitPrice;

  const OrderedItem({
    required this.itemId,
    required this.quantity,
    required this.unitPrice,
    this.storeId,
  });

  @override
  List<Object?> get props => [itemId, storeId, quantity, unitPrice];
}
