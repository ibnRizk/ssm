import 'package:equatable/equatable.dart';

/// One line of the customer's server-side cart.
class CartLine extends Equatable {
  /// The cart line id (`cart_id`), not the item id.
  final int id;
  final int itemId;
  final String name;
  final String? imageUrl;

  /// What one unit costs, as the line was added. The server recomputes
  /// prices when the order is placed.
  final double unitPrice;
  final int quantity;

  /// Null when the backend didn't say which store sells the item.
  final int? storeId;
  final String? storeName;

  const CartLine({
    required this.id,
    required this.itemId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    this.imageUrl,
    this.storeId,
    this.storeName,
  });

  double get lineTotal => unitPrice * quantity;

  @override
  List<Object?> get props => [
    id,
    itemId,
    name,
    imageUrl,
    unitPrice,
    quantity,
    storeId,
    storeName,
  ];
}

class Cart extends Equatable {
  final List<CartLine> lines;

  const Cart(this.lines);

  static const Cart empty = Cart(<CartLine>[]);

  bool get isEmpty => lines.isEmpty;

  /// Units across every line, for the "Cart · N items" bar.
  int get itemCount => lines.fold(0, (int sum, CartLine l) => sum + l.quantity);

  double get subtotal =>
      lines.fold(0, (double sum, CartLine l) => sum + l.lineTotal);

  CartLine? lineForItem(int itemId) {
    for (final CartLine line in lines) {
      if (line.itemId == itemId) return line;
    }
    return null;
  }

  /// An order is placed for one store and built from the whole cart, so the
  /// cart may only hold one store's items. True when adding an item of
  /// [storeId] would mix stores; unknown store ids never conflict.
  bool conflictsWithStore(int? storeId) =>
      storeId != null &&
      lines.any((CartLine l) => l.storeId != null && l.storeId != storeId);

  @override
  List<Object?> get props => [lines];
}
