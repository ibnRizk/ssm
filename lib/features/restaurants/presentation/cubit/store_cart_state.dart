import 'package:equatable/equatable.dart';

/// One line in the mock cart — enough to render both the product card's "+"
/// affordance and the Cart screen's item list without a second lookup into
/// the store's product catalog.
class CartLineItem extends Equatable {
  final String productId;
  final String name;
  final String subtitle;
  final int unitPrice;
  final int quantity;

  const CartLineItem({
    required this.productId,
    required this.name,
    required this.subtitle,
    required this.unitPrice,
    required this.quantity,
  });

  int get lineTotal => unitPrice * quantity;

  CartLineItem copyWith({int? quantity}) {
    return CartLineItem(
      productId: productId,
      name: name,
      subtitle: subtitle,
      unitPrice: unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    productId,
    name,
    subtitle,
    unitPrice,
    quantity,
  ];
}

/// Mock cart state shared by the store-details and cart screens: which
/// products were added (with enough detail to display them) and which
/// add-ons are selected. Not a state *union* (no Loading/Error variants —
/// there's no API yet), so this is one plain immutable value class rather
/// than a sealed hierarchy.
class StoreCartState extends Equatable {
  final Map<String, CartLineItem> items;
  final Set<String> selectedAddonIds;

  const StoreCartState({
    this.items = const <String, CartLineItem>{},
    this.selectedAddonIds = const <String>{},
  });

  int quantityOf(String productId) => items[productId]?.quantity ?? 0;

  bool isAddonSelected(String addonId) => selectedAddonIds.contains(addonId);

  List<CartLineItem> get lineItems => items.values.toList(growable: false);

  int get totalItemCount =>
      items.values.fold(0, (int sum, CartLineItem item) => sum + item.quantity);

  int get subtotal =>
      items.values.fold(0, (int sum, CartLineItem item) => sum + item.lineTotal);

  StoreCartState copyWith({
    Map<String, CartLineItem>? items,
    Set<String>? selectedAddonIds,
  }) {
    return StoreCartState(
      items: items ?? this.items,
      selectedAddonIds: selectedAddonIds ?? this.selectedAddonIds,
    );
  }

  @override
  List<Object?> get props => <Object?>[items, selectedAddonIds];
}
