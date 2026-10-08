import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/core/location/geo_point.dart';
import 'package:ssm/features/catalog/domain/entities/catalog_category.dart';
import 'package:ssm/features/catalog/domain/entities/catalog_page.dart';
import 'package:ssm/features/catalog/domain/entities/store.dart';
import 'package:ssm/features/catalog/domain/entities/store_item.dart';
import 'package:ssm/features/catalog/domain/entities/store_sort.dart';
import 'package:ssm/features/catalog/domain/repos/catalog_repository.dart';

/// One request the fake received; the test answers it through [completer],
/// so ordering and concurrency are explicit rather than timing-dependent.
class PendingCall<T> {
  final String method;
  final int page;
  final String? query;
  final int? categoryId;
  final StoreSort? sort;
  final GeoPoint? origin;
  final Completer<Either<Failure, T>> completer = Completer();

  PendingCall(
    this.method, {
    this.page = 1,
    this.query,
    this.categoryId,
    this.sort,
    this.origin,
  });

  void succeed(T value) => completer.complete(Right<Failure, T>(value));

  void fail(Failure failure) => completer.complete(Left<Failure, T>(failure));
}

class FakeCatalogRepository implements CatalogRepository {
  final List<PendingCall<List<CatalogCategory>>> categoryCalls = [];
  final List<PendingCall<CatalogPage<Store>>> storeCalls = [];
  final List<PendingCall<Store>> detailsCalls = [];
  final List<PendingCall<CatalogPage<StoreItem>>> itemCalls = [];

  @override
  Future<Either<Failure, List<CatalogCategory>>> getCategories() {
    final PendingCall<List<CatalogCategory>> call = PendingCall(
      'getCategories',
    );
    categoryCalls.add(call);
    return call.completer.future;
  }

  @override
  Future<Either<Failure, CatalogPage<Store>>> getStores({
    required int page,
    int pageSize = catalogPageSize,
    StoreSort? sort,
    GeoPoint? origin,
  }) {
    final PendingCall<CatalogPage<Store>> call = PendingCall(
      'getStores',
      page: page,
      sort: sort,
      origin: origin,
    );
    storeCalls.add(call);
    return call.completer.future;
  }

  @override
  Future<Either<Failure, CatalogPage<Store>>> getCategoryStores({
    required int categoryId,
    required int page,
    int pageSize = catalogPageSize,
  }) {
    final PendingCall<CatalogPage<Store>> call = PendingCall(
      'getCategoryStores',
      page: page,
      categoryId: categoryId,
    );
    storeCalls.add(call);
    return call.completer.future;
  }

  @override
  Future<Either<Failure, CatalogPage<Store>>> searchStores({
    required String query,
    required int page,
    int pageSize = catalogPageSize,
  }) {
    final PendingCall<CatalogPage<Store>> call = PendingCall(
      'searchStores',
      page: page,
      query: query,
    );
    storeCalls.add(call);
    return call.completer.future;
  }

  @override
  Future<Either<Failure, Store>> getStoreDetails(int storeId) {
    final PendingCall<Store> call = PendingCall('getStoreDetails');
    detailsCalls.add(call);
    return call.completer.future;
  }

  @override
  Future<Either<Failure, CatalogPage<StoreItem>>> getStoreItems({
    required int storeId,
    required int page,
    int pageSize = catalogPageSize,
  }) {
    final PendingCall<CatalogPage<StoreItem>> call = PendingCall(
      'getStoreItems',
      page: page,
    );
    itemCalls.add(call);
    return call.completer.future;
  }
}

Store fakeStore(int id) => Store(id: id, name: 'Store $id');

StoreItem fakeItem(int id) => StoreItem(id: id, name: 'Item $id', price: 10);

CatalogPage<Store> storesPage(List<int> ids, {required int total}) =>
    CatalogPage<Store>(items: ids.map(fakeStore).toList(), totalSize: total);

CatalogPage<StoreItem> itemsPage(List<int> ids, {required int total}) =>
    CatalogPage<StoreItem>(items: ids.map(fakeItem).toList(), totalSize: total);
