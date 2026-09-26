import '../../../../core/api/json_readers.dart';
import '../../../../core/error/exceptions.dart';
import '../../../catalog/domain/entities/catalog_page.dart';
import '../../domain/entities/order_list_entry.dart';

/// Parsers for the legacy order lists and details. Each throws
/// [ServerException] when the body can't be what the endpoint promises,
/// and reads optional fields leniently — the legacy shapes vary between
/// backend versions.
abstract final class OrdersModels {
  /// `order/running-orders` and `order/list`: `{ total_size, limit, offset,
  /// orders: [...] }`. Unusable orders are skipped.
  static CatalogPage<OrderListEntry> pageFromJson(dynamic json) {
    final dynamic orders = json is Map ? json['orders'] : null;
    if (orders is! List) throw const ServerException();
    final List<OrderListEntry> items = orders
        .map(_entryFromJson)
        .whereType<OrderListEntry>()
        .toList(growable: false);
    return CatalogPage<OrderListEntry>(
      items: items,
      totalSize: jsonInt((json as Map)['total_size']) ?? items.length,
    );
  }

  /// `{ id, order_status, order_amount, created_at, store_id, store: { id,
  /// name }, module: { module_type }, details_count, details? }`.
  static OrderListEntry? _entryFromJson(dynamic json) {
    final int? id = json is Map ? jsonInt(json['id']) : null;
    if (json is! Map || id == null) return null;
    final dynamic store = json['store'];
    final dynamic module = json['module'];
    final String? createdAt = jsonString(json['created_at']);
    final List<OrderItemSummary> items = _itemsFromJson(json['details']);
    return OrderListEntry(
      id: id,
      status: OrderListStatus.fromLegacy(jsonString(json['order_status'])),
      orderAmount: jsonDouble(json['order_amount']),
      createdAt: createdAt == null ? null : DateTime.tryParse(createdAt),
      storeId:
          jsonInt(json['store_id']) ??
          (store is Map ? jsonInt(store['id']) : null),
      storeName: store is Map ? jsonString(store['name']) : null,
      storeKind: storeKindFromWire(
        module is Map ? jsonString(module['module_type']) : null,
      ),
      items: items,
      itemCount:
          jsonInt(json['details_count']) ??
          (items.isEmpty ? null : items.length),
    );
  }

  static List<OrderItemSummary> _itemsFromJson(dynamic details) {
    if (details is! List) return const <OrderItemSummary>[];
    return details
        .map((dynamic line) {
          if (line is! Map) return null;
          final dynamic item = jsonDecodedIfString(line['item_details']);
          final String? name = item is Map ? jsonString(item['name']) : null;
          final int quantity = jsonInt(line['quantity']) ?? 1;
          return name == null || quantity < 1
              ? null
              : OrderItemSummary(name: name, quantity: quantity);
        })
        .whereType<OrderItemSummary>()
        .toList(growable: false);
  }

  static OrderStoreKind storeKindFromWire(String? value) =>
      switch (value?.toLowerCase()) {
        'food' => OrderStoreKind.food,
        'grocery' => OrderStoreKind.grocery,
        'pharmacy' => OrderStoreKind.pharmacy,
        _ => OrderStoreKind.other,
      };

  /// `order/details`: a list of `{ item_id, quantity, price, item_details }`,
  /// where `item_details` (`{ id, store_id, ... }`) may arrive JSON-encoded
  /// as a string. Lines without a quantity or price are skipped; a line
  /// without an item id is kept (it counts as not re-addable).
  static List<OrderedItem> orderedItemsFromJson(dynamic json) {
    if (json is! List) throw const ServerException();
    return json
        .map(_orderedItemFromJson)
        .whereType<OrderedItem>()
        .toList(growable: false);
  }

  static OrderedItem? _orderedItemFromJson(dynamic json) {
    if (json is! Map) return null;
    final dynamic item = jsonDecodedIfString(json['item_details']);
    final int? quantity = jsonInt(json['quantity']);
    final double? price = jsonDouble(json['price']);
    if (quantity == null || quantity < 1 || price == null) return null;
    return OrderedItem(
      itemId:
          jsonInt(json['item_id']) ??
          (item is Map ? jsonInt(item['id']) : null),
      storeId: item is Map ? jsonInt(item['store_id']) : null,
      quantity: quantity,
      unitPrice: price,
    );
  }
}
