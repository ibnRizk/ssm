import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/location/geo_point.dart';
import '../../../../core/zone/zone_repository.dart';
import '../../../../core/zone/zone_scoped_call.dart';
import '../../domain/entities/catalog_category.dart';
import '../../domain/entities/catalog_page.dart';
import '../../domain/entities/store.dart';
import '../../domain/entities/store_item.dart';
import '../../domain/entities/store_sort.dart';
import '../../domain/repos/catalog_repository.dart';
import '../datasources/catalog_remote_data_source.dart';

/// Catalog calls need the zone headers — see [ZoneScopedCall.inZone].
class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource remote;
  final ZoneRepository zoneRepository;

  const CatalogRepositoryImpl({
    required this.remote,
    required this.zoneRepository,
  });

  @override
  Future<Either<Failure, List<CatalogCategory>>> getCategories() =>
      zoneRepository.inZone(remote.getCategories);

  @override
  Future<Either<Failure, CatalogPage<Store>>> getStores({
    required int page,
    int pageSize = catalogPageSize,
    StoreSort? sort,
    GeoPoint? origin,
  }) => zoneRepository.inZone(
    () => remote.getStores(
      page: page,
      limit: pageSize,
      sort: sort,
      origin: origin,
    ),
  );

  @override
  Future<Either<Failure, CatalogPage<Store>>> getCategoryStores({
    required int categoryId,
    required int page,
    int pageSize = catalogPageSize,
  }) => zoneRepository.inZone(
    () => remote.getCategoryStores(
      categoryId: categoryId,
      page: page,
      limit: pageSize,
    ),
  );

  @override
  Future<Either<Failure, CatalogPage<Store>>> searchStores({
    required String query,
    required int page,
    int pageSize = catalogPageSize,
  }) => zoneRepository.inZone(
    () => remote.searchStores(query: query, page: page, limit: pageSize),
  );

  @override
  Future<Either<Failure, Store>> getStoreDetails(int storeId) =>
      zoneRepository.inZone(() => remote.getStoreDetails(storeId));

  @override
  Future<Either<Failure, CatalogPage<StoreItem>>> getStoreItems({
    required int storeId,
    required int page,
    int pageSize = catalogPageSize,
  }) => zoneRepository.inZone(
    () => remote.getStoreItems(storeId: storeId, page: page, limit: pageSize),
  );
}
