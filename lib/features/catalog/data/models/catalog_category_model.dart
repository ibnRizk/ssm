import '../../../../core/api/json_readers.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/catalog_category.dart';

/// `GET /categories` → a bare JSON array of categories.
class CatalogCategoryModel extends CatalogCategory {
  const CatalogCategoryModel({
    required super.id,
    required super.name,
    super.imageUrl,
  });

  /// Null for an entry without an id or name — it can't be shown.
  static CatalogCategoryModel? tryFromJson(dynamic json) {
    if (json is! Map) return null;
    final int? id = jsonInt(json['id']);
    final String? name = jsonString(json['name']);
    if (id == null || name == null) return null;
    return CatalogCategoryModel(
      id: id,
      name: name,
      imageUrl:
          jsonHttpUrl(json['image_full_url']) ?? jsonHttpUrl(json['image']),
    );
  }

  /// Throws [ServerException] when the body isn't a list.
  static List<CatalogCategoryModel> listFromJson(dynamic json) {
    if (json is! List) throw const ServerException();
    return json
        .map(CatalogCategoryModel.tryFromJson)
        .whereType<CatalogCategoryModel>()
        .toList(growable: false);
  }
}
