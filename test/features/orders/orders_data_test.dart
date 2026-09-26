import 'package:dartz/dartz.dart';
import 'package:ssm/core/api/api_endpoints.dart';
import 'package:ssm/core/error/exceptions.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/core/zone/zone_repository.dart';
import 'package:ssm/features/catalog/domain/entities/catalog_page.dart';
import 'package:ssm/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:ssm/features/orders/data/models/orders_models.dart';
import 'package:ssm/features/orders/data/repos/orders_repository_impl.dart';
import 'package:ssm/features/orders/domain/entities/order_list_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_dio_consumer.dart';

class _FakeZoneRepository implements ZoneRepository {
  @override
  Future<Either<Failure, List<int>>> ensureZoneIds() async =>
      const Right<Failure, List<int>>(<int>[1]);

  @override
  Future<Either<Failure, Unit>> selectZoneIds(List<int> zoneIds) =>
      throw UnimplementedError();

  @override
  List<int> get currentZoneIds => throw UnimplementedError();

  @override
  Stream<List<int>> get zoneChanges => throw UnimplementedError();
}

Map<String, dynamic> _page(List<Object?> orders, {int? total}) =>
    <String, dynamic>{
      'total_size': ?total,
      'limit': 10,
      'offset': 1,
      'orders': orders,
    };

void main() {
  group('OrdersModels.pageFromJson', () {
    test('reads status, amount, date, store and item count', () {
      final CatalogPage<OrderListEntry> page = OrdersModels.pageFromJson(
        _page(<Object?>[
          <String, dynamic>{
            'id': 1048,
            'order_status': 'processing',
            'order_amount': '71.50',
            'created_at': '2026-09-26T17:24:00.000000Z',
            'store_id': '7',
            'store': <String, dynamic>{'id': 7, 'name': 'Mazaq'},
            'module': <String, dynamic>{'module_type': 'food'},
            'details_count': 3,
          },
        ], total: 12),
      );

      expect(page.totalSize, 12);
      expect(
        page.items.single,
        OrderListEntry(
          id: 1048,
          status: OrderListStatus.preparing,
          orderAmount: 71.5,
          createdAt: DateTime.utc(2026, 9, 26, 17, 24),
          storeId: 7,
          storeName: 'Mazaq',
          storeKind: OrderStoreKind.food,
          itemCount: 3,
        ),
      );
    });

    test('reads the products when the order carries its details', () {
      final OrderListEntry entry = OrdersModels.pageFromJson(
        _page(<Object?>[
          <String, dynamic>{
            'id': 1,
            'details': <dynamic>[
              <String, dynamic>{
                'quantity': 2,
                'item_details': <String, dynamic>{'name': 'Burger'},
              },
              <String, dynamic>{
                'quantity': '1',
                'item_details': '{"name":"Fries"}',
              },
              <String, dynamic>{'quantity': 1, 'item_details': '{'},
            ],
          },
        ]),
      ).items.single;

      expect(entry.items, const <OrderItemSummary>[
        OrderItemSummary(name: 'Burger', quantity: 2),
        OrderItemSummary(name: 'Fries', quantity: 1),
      ]);
      expect(entry.itemCount, 2);
    });

    test('skips orders without an id; total falls back to the count', () {
      final CatalogPage<OrderListEntry> page = OrdersModels.pageFromJson(
        _page(<Object?>[
          <String, dynamic>{'order_status': 'pending'},
          'junk',
          <String, dynamic>{'id': 2},
        ]),
      );

      expect(page.items.map((OrderListEntry e) => e.id), <int>[2]);
      expect(page.totalSize, 1);
      expect(page.items.single.status, OrderListStatus.pending);
      expect(page.items.single.storeKind, OrderStoreKind.other);
    });

    test('throws ServerException without an orders list', () {
      expect(
        () => OrdersModels.pageFromJson(<String, dynamic>{'orders': null}),
        throwsA(isA<ServerException>()),
      );
    });
  });

  test('every legacy order_status maps to a list status', () {
    const Map<String?, OrderListStatus> wire = <String?, OrderListStatus>{
      'pending': OrderListStatus.pending,
      'accepted': OrderListStatus.preparing,
      'confirmed': OrderListStatus.preparing,
      'processing': OrderListStatus.preparing,
      'handover': OrderListStatus.awaitingCourier,
      'picked_up': OrderListStatus.onTheWay,
      'delivered': OrderListStatus.delivered,
      'refund_request_canceled': OrderListStatus.delivered,
      'canceled': OrderListStatus.cancelled,
      'failed': OrderListStatus.cancelled,
      'refund_requested': OrderListStatus.refunded,
      'refunded': OrderListStatus.refunded,
      'teleported': OrderListStatus.pending,
      null: OrderListStatus.pending,
    };
    for (final MapEntry<String?, OrderListStatus> e in wire.entries) {
      expect(OrderListStatus.fromLegacy(e.key), e.value, reason: e.key);
    }
  });

  group('OrdersModels.orderedItemsFromJson', () {
    test('reads the item and store id, from item_details as a fallback', () {
      expect(
        OrdersModels.orderedItemsFromJson(<dynamic>[
          <String, dynamic>{
            'item_id': 10,
            'quantity': 2,
            'price': '20',
            'item_details': '{"id":10,"store_id":7}',
          },
          <String, dynamic>{
            'item_id': null,
            'quantity': 1,
            'price': 5.5,
            'item_details': <String, dynamic>{'id': 11, 'store_id': '7'},
          },
        ]),
        const <OrderedItem>[
          OrderedItem(itemId: 10, storeId: 7, quantity: 2, unitPrice: 20),
          OrderedItem(itemId: 11, storeId: 7, quantity: 1, unitPrice: 5.5),
        ],
      );
    });

    test('keeps a line without an item id; skips one without a price', () {
      expect(
        OrdersModels.orderedItemsFromJson(<dynamic>[
          <String, dynamic>{'item_campaign_id': 3, 'quantity': 1, 'price': 9},
          <String, dynamic>{'item_id': 10, 'quantity': 1},
          <String, dynamic>{'item_id': 10, 'quantity': 0, 'price': 9},
        ]),
        const <OrderedItem>[
          OrderedItem(itemId: null, quantity: 1, unitPrice: 9),
        ],
      );
    });

    test('throws ServerException when the body is not a list', () {
      expect(
        () => OrdersModels.orderedItemsFromJson(<String, dynamic>{}),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('OrdersRepositoryImpl', () {
    late FakeDioConsumer consumer;
    late OrdersRepositoryImpl repository;

    setUp(() {
      consumer = FakeDioConsumer(response: _page(<Object?>[]));
      repository = OrdersRepositoryImpl(
        remote: OrdersRemoteDataSourceImpl(consumer: consumer),
        zoneRepository: _FakeZoneRepository(),
      );
    });

    test('running orders page with offset (1-based) and limit', () async {
      await repository.getRunningOrders(page: 2);

      expect(consumer.lastPath, ApiEndpoints.runningOrders);
      expect(consumer.lastQuery, <String, dynamic>{'offset': 2, 'limit': 10});
    });

    test('past orders come from the order list', () async {
      await repository.getPastOrders(page: 1);

      expect(consumer.lastPath, ApiEndpoints.orderHistory);
      expect(consumer.lastQuery, <String, dynamic>{'offset': 1, 'limit': 10});
    });

    test('ordered items come from the details, by order_id', () async {
      consumer.response = <dynamic>[];

      await repository.getOrderedItems(9);

      expect(consumer.lastPath, ApiEndpoints.orderDetails);
      expect(consumer.lastQuery, <String, dynamic>{'order_id': 9});
    });

    test('a foreign order is a NotFoundFailure', () async {
      consumer.error = const NotFoundException();

      expect(
        await repository.getOrderedItems(9),
        const Left<Failure, List<OrderedItem>>(NotFoundFailure()),
      );
    });
  });
}
