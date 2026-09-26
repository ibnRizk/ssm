import '../../../../core/api/json_readers.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/catalog_page.dart';
import '../../domain/entities/store.dart';

/// A store as returned by the store list, search and details endpoints.
class StoreModel extends Store {
  const StoreModel({
    required super.id,
    required super.name,
    super.logoUrl,
    super.coverUrl,
    super.address,
    super.rating,
    super.ratingCount,
    super.deliveryTime,
    super.minimumDeliveryFee,
    super.freeDelivery,
    super.minimumOrder,
    super.isOpen,
    super.tags,
  });

  /// Null for an entry without an id or name — it can't be opened.
  static StoreModel? tryFromJson(dynamic json) {
    if (json is! Map) return null;
    final int? id = jsonInt(json['id']);
    final String? name = jsonString(json['name']);
    if (id == null || name == null) return null;
    return StoreModel(
      id: id,
      name: name,
      logoUrl: jsonHttpUrl(json['logo_full_url']) ?? jsonHttpUrl(json['logo']),
      coverUrl:
          jsonHttpUrl(json['cover_photo_full_url']) ??
          jsonHttpUrl(json['cover_photo']),
      address: jsonString(json['address']),
      // `rating` is a per-star histogram on this backend, not the average.
      rating: jsonDouble(json['avg_rating']) ?? 0,
      ratingCount: jsonInt(json['rating_count']) ?? 0,
      deliveryTime: jsonString(json['delivery_time']),
      minimumDeliveryFee: jsonDouble(json['minimum_shipping_charge']),
      freeDelivery: jsonBool(json['free_delivery']) ?? false,
      minimumOrder: jsonDouble(json['minimum_order']),
      isOpen: _isOpen(json),
      tags: _tags(json['cuisine']),
    );
  }

  /// `GET /stores/details/{id}` → the store object at the top level.
  /// Throws [ServerException] when it isn't a usable store.
  factory StoreModel.fromJson(dynamic json) =>
      tryFromJson(json) ?? (throw const ServerException());

  /// `{ "total_size", "limit", "offset", "stores": [...] }` — the store list
  /// and search share it. Throws [ServerException] without a `stores` list.
  static CatalogPage<Store> pageFromJson(dynamic json) {
    final dynamic stores = json is Map ? json['stores'] : null;
    if (stores is! List) throw const ServerException();
    final List<StoreModel> items = stores
        .map(StoreModel.tryFromJson)
        .whereType<StoreModel>()
        .toList(growable: false);
    return CatalogPage<Store>(
      items: items,
      totalSize: jsonInt((json as Map)['total_size']) ?? items.length,
    );
  }

  /// A deactivated store is closed whatever `open` says.
  static bool? _isOpen(Map<dynamic, dynamic> json) {
    if (jsonBool(json['active']) == false) return false;
    return jsonBool(json['open']);
  }

  static List<String> _tags(dynamic cuisines) => cuisines is List
      ? cuisines
            .map((dynamic c) => c is Map ? jsonString(c['name']) : null)
            .whereType<String>()
            .toList(growable: false)
      : const <String>[];
}
