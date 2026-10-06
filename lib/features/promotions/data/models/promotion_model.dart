import '../../../../core/api/json_readers.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/store_promotion.dart';

/// A promotion as returned by `GET /stores/featured-promotions`.
///
/// `store_path`, `store_url` and the desktop banner are ignored on purpose:
/// the app opens the store by id, never a link from the response.
class PromotionModel extends StorePromotion {
  const PromotionModel({
    required super.id,
    required super.storeId,
    super.storeName,
    super.bannerUrl,
    super.videoUrl,
  });

  /// Null for an entry that can't be opened (no id, no store) or has nothing
  /// to show (no banner and no store name).
  static PromotionModel? tryFromJson(dynamic json) {
    if (json is! Map) return null;
    final dynamic store = json['store'];
    final int? id = jsonInt(json['id']);
    final int? storeId =
        jsonInt(json['store_id']) ??
        (store is Map ? jsonInt(store['id']) : null);
    final String? storeName = store is Map ? jsonString(store['name']) : null;
    final String? bannerUrl = jsonHttpUrl(json['mobile_banner_url']);
    if (id == null || storeId == null) return null;
    if (bannerUrl == null && storeName == null) return null;
    return PromotionModel(
      id: id,
      storeId: storeId,
      storeName: storeName,
      bannerUrl: bannerUrl,
      videoUrl: jsonHttpUrl(json['video_url']),
    );
  }

  /// `{ "total_size", "limit", "offset", "promotions": [...] }`, skipping
  /// unusable entries. Throws [ServerException] without a `promotions` list.
  static List<PromotionModel> listFromJson(dynamic json) {
    final dynamic promotions = json is Map ? json['promotions'] : null;
    if (promotions is! List) throw const ServerException();
    return promotions
        .map(PromotionModel.tryFromJson)
        .whereType<PromotionModel>()
        .toList(growable: false);
  }
}
