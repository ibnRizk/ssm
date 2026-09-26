import 'package:dartz/dartz.dart';
import 'package:ssm/core/api/api_endpoints.dart';
import 'package:ssm/core/error/exceptions.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/core/zone/zone_repository.dart';
import 'package:ssm/features/catalog/data/datasources/catalog_remote_data_source.dart';
import 'package:ssm/features/catalog/data/models/catalog_category_model.dart';
import 'package:ssm/features/catalog/data/models/store_item_model.dart';
import 'package:ssm/features/catalog/data/models/store_model.dart';
import 'package:ssm/features/catalog/data/repos/catalog_repository_impl.dart';
import 'package:ssm/features/catalog/domain/entities/catalog_category.dart';
import 'package:ssm/features/catalog/domain/entities/catalog_page.dart';
import 'package:ssm/features/catalog/domain/entities/store.dart';
import 'package:ssm/features/catalog/domain/entities/store_item.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_dio_consumer.dart';

class _FakeZoneRepository implements ZoneRepository {
  Either<Failure, List<int>> answer = const Right<Failure, List<int>>(<int>[1]);
  int calls = 0;

  @override
  Future<Either<Failure, List<int>>> ensureZoneIds() async {
    calls++;
    return answer;
  }

  @override
  Future<Either<Failure, Unit>> selectZoneIds(List<int> zoneIds) =>
      throw UnimplementedError();

  @override
  List<int> get currentZoneIds => throw UnimplementedError();

  @override
  Stream<List<int>> get zoneChanges => throw UnimplementedError();
}

Map<String, dynamic> _storeJson({Object? id = 1, Object? name = 'Mazaq'}) =>
    <String, dynamic>{'id': id, 'name': name};

void main() {
  group('CatalogCategoryModel.listFromJson', () {
    test('reads a bare array, skipping unusable entries', () {
      final List<CatalogCategoryModel> categories =
          CatalogCategoryModel.listFromJson(<dynamic>[
            <String, dynamic>{
              'id': 1,
              'name': 'Burgers',
              'image_full_url': 'https://cdn.example.com/c/1.png',
            },
            <String, dynamic>{'id': '2', 'name': 'Pizza', 'image': 'x.png'},
            <String, dynamic>{'name': 'No id'},
          ]);

      // Props, not ==: a model never equals its entity (runtimeType differs).
      expect(categories.map((CatalogCategory c) => c.props), <List<Object?>>[
        const CatalogCategory(
          id: 1,
          name: 'Burgers',
          imageUrl: 'https://cdn.example.com/c/1.png',
        ).props,
        // A bare file name can't be loaded, so there's no image.
        const CatalogCategory(id: 2, name: 'Pizza').props,
      ]);
    });

    test('reads the per-language names', () {
      final CatalogCategory category = CatalogCategoryModel.listFromJson(
        <dynamic>[
          <String, dynamic>{
            'id': 4,
            'name': 'Restaurants',
            'name_ar': 'مطاعم',
            'name_en': 'Restaurants',
            'image_full_url': 'https://cdn.example.com/c/4.png',
          },
        ],
      ).single;

      expect(
        category.props,
        const CatalogCategory(
          id: 4,
          name: 'Restaurants',
          nameAr: 'مطاعم',
          nameEn: 'Restaurants',
          imageUrl: 'https://cdn.example.com/c/4.png',
        ).props,
      );
    });

    test('without name, falls back to a per-language one', () {
      final CatalogCategory category = CatalogCategoryModel.listFromJson(
        <dynamic>[
          <String, dynamic>{'id': 4, 'name': ' ', 'name_ar': 'مطاعم'},
        ],
      ).single;

      expect(category.name, 'مطاعم');
    });

    test('throws ServerException when the body is not a list', () {
      expect(
        () => CatalogCategoryModel.listFromJson(<String, dynamic>{}),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('StoreModel', () {
    test('maps the store fields the app shows', () {
      final Store store = StoreModel.fromJson(<String, dynamic>{
        'id': 7,
        'name': 'Mazaq',
        'logo_full_url': 'https://cdn.example.com/s/7.png',
        'address': 'Turbah',
        'avg_rating': '4.8',
        'rating_count': 120,
        // A per-star histogram on this backend — not the average.
        'rating': <int>[100, 10, 5, 3, 2],
        'delivery_time': '25-35 min',
        'minimum_shipping_charge': '7.00',
        'free_delivery': 0,
        'minimum_order': 20,
        'active': 1,
        'open': 1,
        'cuisine': <dynamic>[
          <String, dynamic>{'id': 1, 'name': 'Burger'},
          <String, dynamic>{'id': 2, 'name': 'Grill'},
        ],
      });

      expect(
        store.props,
        const Store(
          id: 7,
          name: 'Mazaq',
          logoUrl: 'https://cdn.example.com/s/7.png',
          address: 'Turbah',
          rating: 4.8,
          ratingCount: 120,
          deliveryTime: '25-35 min',
          minimumDeliveryFee: 7,
          minimumOrder: 20,
          isOpen: true,
          tags: <String>['Burger', 'Grill'],
        ).props,
      );
    });

    test('reads the category, delivery time, distance and cover', () {
      final Store store = StoreModel.fromJson(<String, dynamic>{
        ..._storeJson(),
        'cover_photo_full_url': 'https://cdn.example.com/s/c.png',
        'ssm_store_category_id': '4',
        'min_delivery_time': 25,
        'distance': '2.75',
      });

      expect(store.coverUrl, 'https://cdn.example.com/s/c.png');
      expect(store.storeCategoryId, 4);
      expect(store.minDeliveryTime, 25);
      expect(store.distance, 2.75);
    });

    test('drops an unset delivery time and a negative distance', () {
      final Store store = StoreModel.fromJson(<String, dynamic>{
        ..._storeJson(),
        'min_delivery_time': 0,
        'distance': -1,
      });

      expect(store.minDeliveryTime, isNull);
      expect(store.distance, isNull);
    });

    test('ignores the bare logo and cover file names', () {
      final Store store = StoreModel.fromJson(<String, dynamic>{
        ..._storeJson(),
        'logo': 'https://cdn.example.com/legacy.png',
        'cover_photo': 'https://cdn.example.com/legacy.png',
      });

      expect(store.logoUrl, isNull);
      expect(store.coverUrl, isNull);
    });

    test('a deactivated store is closed whatever open says', () {
      final Store store = StoreModel.fromJson(<String, dynamic>{
        ..._storeJson(),
        'active': false,
        'open': 1,
      });

      expect(store.isOpen, isFalse);
    });

    test('leaves isOpen null when the backend does not say', () {
      expect(StoreModel.fromJson(_storeJson()).isOpen, isNull);
    });

    test('fromJson throws ServerException without an id', () {
      expect(
        () => StoreModel.fromJson(_storeJson(id: null)),
        throwsA(isA<ServerException>()),
      );
    });

    test('pageFromJson reads stores and the total, skipping bad ones', () {
      final CatalogPage<Store> page = StoreModel.pageFromJson(<String, dynamic>{
        'total_size': '12',
        'limit': 10,
        'offset': 1,
        'stores': <dynamic>[_storeJson(), _storeJson(name: null)],
      });

      expect(page.items.map((Store s) => s.id), <int>[1]);
      expect(page.totalSize, 12);
    });

    test('pageFromJson reads a live get-stores/all store as sent', () {
      // Trimmed from a real response: a double distance, string
      // coordinates and nested storage/schedules must not drop the store.
      final CatalogPage<Store> page = StoreModel.pageFromJson(<String, dynamic>{
        'total_size': 8,
        'limit': '50',
        'offset': '1',
        'stores': <dynamic>[
          <String, dynamic>{
            'id': 5,
            'name': 'test feature',
            'logo': '2026-09-24-6ab53fb555e79.png',
            'latitude': '30.046341336599',
            'longitude': '31.378952968024',
            'address': 'test location',
            'minimum_order': 0,
            'comission': null,
            'status': 1,
            'free_delivery': false,
            'cover_photo': '2026-09-24-6ab53fb55a491.png',
            'active': true,
            'off_day': ' ',
            'minimum_shipping_charge': 0,
            'delivery_time': '15-30 min',
            'ssm_store_category_id': 2,
            'open': 1,
            'distance': 4709346.614683684,
            'min_delivery_time': '15',
            'category_ids': <int>[2, 1, 10],
            'ratings': <int>[0, 0, 0, 0, 0],
            'avg_rating': 0,
            'rating_count': 0,
            'logo_full_url':
                'https://ssm.husseintech.com/storage/app/public/store/2026-09-24-6ab53fb555e79.png',
            'cover_photo_full_url':
                'https://ssm.husseintech.com/storage/app/public/store/cover/2026-09-24-6ab53fb55a491.png',
            'meta_image_full_url': null,
            'discount': null,
            'translations': <dynamic>[],
            'storage': <dynamic>[
              <String, dynamic>{'id': 97, 'key': 'logo', 'value': 'public'},
            ],
            'schedules': <dynamic>[
              <String, dynamic>{
                'id': 18,
                'store_id': 5,
                'day': 0,
                'opening_time': '10:00:00',
                'closing_time': '22:00:00',
              },
            ],
          },
        ],
      });

      final Store store = page.items.single;
      expect(page.totalSize, 8);
      expect(store.id, 5);
      expect(store.storeCategoryId, 2);
      expect(store.distance, 4709346.614683684);
      expect(store.minDeliveryTime, 15);
      expect(store.isOpen, isTrue);
      expect(
        store.logoUrl,
        'https://ssm.husseintech.com/storage/app/public/store/2026-09-24-6ab53fb555e79.png',
      );
      expect(
        store.coverUrl,
        'https://ssm.husseintech.com/storage/app/public/store/cover/2026-09-24-6ab53fb55a491.png',
      );
    });

    test('pageFromJson throws ServerException without a stores list', () {
      expect(
        () => StoreModel.pageFromJson(<String, dynamic>{'total_size': 0}),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('StoreItemModel.pageFromJson', () {
    test('reads products with their discount', () {
      final CatalogPage<StoreItem> page = StoreItemModel.pageFromJson(
        <String, dynamic>{
          'total_size': 1,
          'products': <dynamic>[
            <String, dynamic>{
              'id': 3,
              'name': 'SSM Burger Meal',
              'description': 'Beef burger, fries and a drink',
              'price': '28.00',
              'discount': 10,
              'discount_type': 'percent',
              'store_id': 7,
            },
          ],
        },
      );

      expect(
        page.items.single.props,
        const StoreItem(
          id: 3,
          name: 'SSM Burger Meal',
          description: 'Beef burger, fries and a drink',
          price: 28,
          discount: 10,
          discountType: DiscountType.percent,
          storeId: 7,
        ).props,
      );
    });

    test('skips a product without a price', () {
      final CatalogPage<StoreItem> page = StoreItemModel.pageFromJson(
        <String, dynamic>{
          'total_size': 1,
          'products': <dynamic>[
            <String, dynamic>{'id': 3, 'name': 'Free?'},
          ],
        },
      );

      expect(page.items, isEmpty);
    });
  });

  group('CatalogRemoteDataSource', () {
    test('stores are paged by the 1-based offset', () async {
      final FakeDioConsumer consumer = FakeDioConsumer(
        response: <String, dynamic>{'total_size': 0, 'stores': <dynamic>[]},
      );

      await CatalogRemoteDataSourceImpl(
        consumer: consumer,
      ).getStores(page: 2, limit: 10);

      expect(consumer.lastPath, ApiEndpoints.allStores);
      expect(consumer.lastQuery, <String, dynamic>{'offset': 2, 'limit': 10});
    });

    test("a category's stores go to its path, paged the same way", () async {
      final FakeDioConsumer consumer = FakeDioConsumer(
        response: <String, dynamic>{
          'total_size': 1,
          'stores': <dynamic>[_storeJson(id: 9)],
        },
      );

      final CatalogPage<Store> page = await CatalogRemoteDataSourceImpl(
        consumer: consumer,
      ).getCategoryStores(categoryId: 4, page: 2, limit: 10);

      expect(consumer.lastPath, '/api/v1/categories/stores/4');
      expect(consumer.lastQuery, <String, dynamic>{'offset': 2, 'limit': 10});
      expect(page.items.single.id, 9);
    });

    test('a search sends the name', () async {
      final FakeDioConsumer consumer = FakeDioConsumer(
        response: <String, dynamic>{'total_size': 0, 'stores': <dynamic>[]},
      );

      await CatalogRemoteDataSourceImpl(
        consumer: consumer,
      ).searchStores(query: 'burger', page: 1, limit: 10);

      expect(consumer.lastPath, ApiEndpoints.searchStores);
      expect(consumer.lastQuery?['name'], 'burger');
    });

    test('store details go to the store id path', () async {
      final FakeDioConsumer consumer = FakeDioConsumer(
        response: _storeJson(id: 7),
      );

      await CatalogRemoteDataSourceImpl(consumer: consumer).getStoreDetails(7);

      expect(consumer.lastPath, ApiEndpoints.storeDetails(7));
    });

    test('store items filter by store, across every category', () async {
      final FakeDioConsumer consumer = FakeDioConsumer(
        response: <String, dynamic>{'total_size': 0, 'products': <dynamic>[]},
      );

      await CatalogRemoteDataSourceImpl(
        consumer: consumer,
      ).getStoreItems(storeId: 7, page: 1, limit: 10);

      expect(consumer.lastPath, ApiEndpoints.latestItems);
      expect(consumer.lastQuery, <String, dynamic>{
        'store_id': 7,
        'category_id': 0,
        'offset': 1,
        'limit': 10,
        'type': 'all',
      });
    });
  });

  group('CatalogRepositoryImpl', () {
    late FakeDioConsumer consumer;
    late _FakeZoneRepository zone;
    late CatalogRepositoryImpl repository;

    setUp(() {
      consumer = FakeDioConsumer(response: <dynamic>[]);
      zone = _FakeZoneRepository();
      repository = CatalogRepositoryImpl(
        remote: CatalogRemoteDataSourceImpl(consumer: consumer),
        zoneRepository: zone,
      );
    });

    test('resolves the zone before calling the catalog', () async {
      final Either<Failure, List<CatalogCategory>> result = await repository
          .getCategories();

      expect(result.isRight(), isTrue);
      expect(zone.calls, 1);
      expect(consumer.lastPath, ApiEndpoints.categories);
    });

    test('without a zone, fails without calling the catalog', () async {
      zone.answer = const Left<Failure, List<int>>(ZoneUnavailableFailure());

      final Either<Failure, List<CatalogCategory>> result = await repository
          .getCategories();

      expect(
        result,
        const Left<Failure, List<CatalogCategory>>(ZoneUnavailableFailure()),
      );
      expect(consumer.lastPath, isNull);
    });

    test("a category's stores need the zone too", () async {
      zone.answer = const Left<Failure, List<int>>(ZoneUnavailableFailure());

      final Either<Failure, CatalogPage<Store>> result = await repository
          .getCategoryStores(categoryId: 4, page: 1);

      expect(
        result,
        const Left<Failure, CatalogPage<Store>>(ZoneUnavailableFailure()),
      );
      expect(consumer.lastPath, isNull);
    });

    test('maps a thrown exception to a failure', () async {
      consumer.error = const ServerException(message: 'Store not found');

      final Either<Failure, Store> result = await repository.getStoreDetails(
        999,
      );

      expect(
        result,
        const Left<Failure, Store>(ServerFailure(message: 'Store not found')),
      );
    });
  });
}
