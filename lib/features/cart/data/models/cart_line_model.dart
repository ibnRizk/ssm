import '../../../../core/api/json_readers.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/cart.dart';

/// One entry of the cart array every cart endpoint answers with:
/// `{ id, item_id, price, quantity, item: { name, image_full_url, store_id,
/// store_name, ... } }`.
class CartLineModel extends CartLine {
  const CartLineModel({
    required super.id,
    required super.itemId,
    required super.name,
    required super.unitPrice,
    required super.quantity,
    super.imageUrl,
    super.storeId,
    super.storeName,
  });

  /// Null for a line missing its ids, price or a positive quantity — it
  /// can't be changed or priced, so the cart skips it.
  static CartLineModel? tryFromJson(dynamic json) {
    if (json is! Map) return null;
    final dynamic item = json['item'];
    final Map<dynamic, dynamic> details = item is Map ? item : const {};
    final int? id = jsonInt(json['id']);
    final int? itemId = jsonInt(json['item_id']) ?? jsonInt(details['id']);
    final double? price = jsonDouble(json['price']);
    final int? quantity = jsonInt(json['quantity']);
    if (id == null ||
        itemId == null ||
        price == null ||
        quantity == null ||
        quantity < 1) {
      return null;
    }
    return CartLineModel(
      id: id,
      itemId: itemId,
      name: jsonString(details['name']) ?? '#$itemId',
      unitPrice: price,
      quantity: quantity,
      imageUrl:
          jsonHttpUrl(details['image_full_url']) ??
          jsonHttpUrl(details['image']),
      storeId: jsonInt(details['store_id']),
      storeName: jsonString(details['store_name']),
    );
  }

  /// The bare array of lines. Throws [ServerException] when it isn't one.
  static Cart cartFromJson(dynamic json) {
    if (json is! List) throw const ServerException();
    return Cart(
      json
          .map(CartLineModel.tryFromJson)
          .whereType<CartLineModel>()
          .toList(growable: false),
    );
  }
}
