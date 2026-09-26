import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/catalog_category.dart';
import '../entities/catalog_page.dart';
import '../entities/store.dart';
import '../entities/store_item.dart';

/// Everything here is scoped to the customer's delivery zone, resolved
/// before the first call; a [ZoneUnavailableFailure] means there's none to
/// browse.
abstract class CatalogRepository {
  Future<Either<Failure, List<CatalogCategory>>> getCategories();

  /// [page] is 1-based.
  Future<Either<Failure, CatalogPage<Store>>> getStores({
    required int page,
    int pageSize = catalogPageSize,
  });

  /// Stores whose name matches [query]. [page] is 1-based.
  Future<Either<Failure, CatalogPage<Store>>> searchStores({
    required String query,
    required int page,
    int pageSize = catalogPageSize,
  });

  /// A missing store answers 404.
  Future<Either<Failure, Store>> getStoreDetails(int storeId);

  /// The store's items, newest first. [page] is 1-based.
  Future<Either<Failure, CatalogPage<StoreItem>>> getStoreItems({
    required int storeId,
    required int page,
    int pageSize = catalogPageSize,
  });
}

const int catalogPageSize = 10;
