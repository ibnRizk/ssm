import '../../../../core/api/json_readers.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/catalog_page.dart';
import '../../domain/entities/store_item.dart';

/// One product of `GET /items/latest`.
class StoreItemModel extends StoreItem {
  const StoreItemModel({
    required super.id,
    required super.name,
    required super.price,
    super.description,
    super.imageUrl,
    super.discount,
    super.discountType,
    super.storeId,
  });

  /// Null for an entry without an id, name or price — it can't be sold.
  static StoreItemModel? tryFromJson(dynamic json) {
    if (json is! Map) return null;
    final int? id = jsonInt(json['id']);
    final String? name = jsonString(json['name']);
    final double? price = jsonDouble(json['price']);
    if (id == null || name == null || price == null) return null;
    return StoreItemModel(
      id: id,
      name: name,
      price: price,
      description: jsonString(json['description']),
      imageUrl:
          jsonHttpUrl(json['image_full_url']) ?? jsonHttpUrl(json['image']),
      discount: jsonDouble(json['discount']) ?? 0,
      discountType: jsonString(json['discount_type']) == 'percent'
          ? DiscountType.percent
          : DiscountType.amount,
      storeId: jsonInt(json['store_id']),
    );
  }

  /// `{ "total_size", "limit", "offset", "products": [...] }`. Throws
  /// [ServerException] without a `products` list.
  static CatalogPage<StoreItem> pageFromJson(dynamic json) {
    final dynamic products = json is Map ? json['products'] : null;
    if (products is! List) throw const ServerException();
    final List<StoreItemModel> items = products
        .map(StoreItemModel.tryFromJson)
        .whereType<StoreItemModel>()
        .toList(growable: false);
    return CatalogPage<StoreItem>(
      items: items,
      totalSize: jsonInt((json as Map)['total_size']) ?? items.length,
    );
  }
}
