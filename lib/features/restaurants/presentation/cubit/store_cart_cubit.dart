import 'package:flutter_bloc/flutter_bloc.dart';

import 'store_cart_state.dart';

/// Owns the mock cart shared by the store-details and cart screens — adding
/// a product, changing its quantity, toggling an add-on. This is feature
/// state (it feeds the Cart screen, and will feed a real checkout once
/// ordering exists), not a UI-only toggle, so it lives in a cubit rather
/// than `setState` per the project's state-management rule.
///
/// TODO: replace with a real cart repository once the ordering API exists.
class StoreCartCubit extends Cubit<StoreCartState> {
  StoreCartCubit() : super(const StoreCartState());

  void addProduct({
    required String productId,
    required String name,
    required String subtitle,
    required int unitPrice,
  }) {
    final CartLineItem? existing = state.items[productId];
    final Map<String, CartLineItem> updated = Map<String, CartLineItem>.of(
      state.items,
    );
    updated[productId] =
        existing?.copyWith(quantity: existing.quantity + 1) ??
        CartLineItem(
          productId: productId,
          name: name,
          subtitle: subtitle,
          unitPrice: unitPrice,
          quantity: 1,
        );
    emit(state.copyWith(items: updated));
  }

  void removeProduct(String productId) {
    final CartLineItem? existing = state.items[productId];
    if (existing == null) return;

    final Map<String, CartLineItem> updated = Map<String, CartLineItem>.of(
      state.items,
    );
    if (existing.quantity <= 1) {
      updated.remove(productId);
    } else {
      updated[productId] = existing.copyWith(quantity: existing.quantity - 1);
    }
    emit(state.copyWith(items: updated));
  }

  void toggleAddon(String addonId) {
    final Set<String> updated = Set<String>.of(state.selectedAddonIds);
    if (!updated.remove(addonId)) updated.add(addonId);
    emit(state.copyWith(selectedAddonIds: updated));
  }
}
