import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../../../core/location/geo_point.dart';
import '../../domain/entities/catalog_page.dart';
import '../../domain/entities/store.dart';
import '../../domain/entities/store_item.dart';
import '../../domain/entities/store_sort.dart';
import '../models/catalog_category_model.dart';
import '../models/store_item_model.dart';
import '../models/store_model.dart';

/// The zone headers these endpoints need are added by `AppInterceptors`.
abstract class CatalogRemoteDataSource {
  Future<List<CatalogCategoryModel>> getCategories();

  /// [origin], when given, is sent as the `latitude`/`longitude` headers
  /// that [StoreSort.nearest] measures from.
  Future<CatalogPage<Store>> getStores({
    required int page,
    required int limit,
    StoreSort? sort,
    GeoPoint? origin,
  });

  Future<CatalogPage<Store>> getCategoryStores({
    required int categoryId,
    required int page,
    required int limit,
  });

  Future<CatalogPage<Store>> searchStores({
    required String query,
    required int page,
    required int limit,
  });

  Future<StoreModel> getStoreDetails(int storeId);

  Future<CatalogPage<StoreItem>> getStoreItems({
    required int storeId,
    required int page,
    required int limit,
  });
}

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  final DioConsumer consumer;

  const CatalogRemoteDataSourceImpl({required this.consumer});

  @override
  Future<List<CatalogCategoryModel>> getCategories() async =>
      CatalogCategoryModel.listFromJson(
        await consumer.get(ApiEndpoints.categories),
      );

  @override
  Future<CatalogPage<Store>> getStores({
    required int page,
    required int limit,
    StoreSort? sort,
    GeoPoint? origin,
  }) async => StoreModel.pageFromJson(
    await consumer.get(
      ApiEndpoints.allStores,
      queryParameters: <String, dynamic>{
        'offset': page,
        'limit': limit,
        if (sort != null) 'sort_by': _sortBy(sort),
      },
      headers: origin == null
          ? null
          : <String, String>{
              'latitude': '${origin.latitude}',
              'longitude': '${origin.longitude}',
            },
    ),
  );

  static String _sortBy(StoreSort sort) => switch (sort) {
    StoreSort.nearest => 'nearest',
    StoreSort.topRated => 'top_rated',
    StoreSort.fastest => 'fastest',
  };

  @override
  Future<CatalogPage<Store>> getCategoryStores({
    required int categoryId,
    required int page,
    required int limit,
  }) async => StoreModel.pageFromJson(
    await consumer.get(
      ApiEndpoints.categoryStores(categoryId),
      queryParameters: <String, dynamic>{'offset': page, 'limit': limit},
    ),
  );

  @override
  Future<CatalogPage<Store>> searchStores({
    required String query,
    required int page,
    required int limit,
  }) async => StoreModel.pageFromJson(
    await consumer.get(
      ApiEndpoints.searchStores,
      queryParameters: <String, dynamic>{
        'name': query,
        'offset': page,
        'limit': limit,
      },
    ),
  );

  @override
  Future<StoreModel> getStoreDetails(int storeId) async => StoreModel.fromJson(
    await consumer.get(ApiEndpoints.storeDetails(storeId)),
  );

  /// `category_id=0` means every category; `type=all` every dietary type.
  @override
  Future<CatalogPage<StoreItem>> getStoreItems({
    required int storeId,
    required int page,
    required int limit,
  }) async => StoreItemModel.pageFromJson(
    await consumer.get(
      ApiEndpoints.latestItems,
      queryParameters: <String, dynamic>{
        'store_id': storeId,
        'category_id': 0,
        'offset': page,
        'limit': limit,
        'type': 'all',
      },
    ),
  );
}
