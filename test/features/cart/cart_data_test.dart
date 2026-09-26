import 'package:dartz/dartz.dart';
import 'package:ssm/core/api/api_endpoints.dart';
import 'package:ssm/core/error/exceptions.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/core/zone/zone_repository.dart';
import 'package:ssm/features/cart/data/datasources/cart_remote_data_source.dart';
import 'package:ssm/features/cart/data/models/cart_line_model.dart';
import 'package:ssm/features/cart/data/repos/cart_repository_impl.dart';
import 'package:ssm/features/cart/domain/entities/cart.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_dio_consumer.dart';

class _FakeZoneRepository implements ZoneRepository {
  Either<Failure, List<int>> answer = const Right<Failure, List<int>>(<int>[1]);

  @override
  Future<Either<Failure, List<int>>> ensureZoneIds() async => answer;

  @override
  Future<Either<Failure, Unit>> selectZoneIds(List<int> zoneIds) =>
      throw UnimplementedError();
}

Map<String, dynamic> _lineJson({
  Object? id = 11,
  Object? quantity = 2,
  Object? price = '12.50',
}) => <String, dynamic>{
  'id': id,
  'item_id': 3,
  'price': price,
  'quantity': quantity,
  'item': <String, dynamic>{
    'id': 3,
    'name': 'SSM Burger Meal',
    'image_full_url': 'https://cdn.example.com/i/3.png',
    'store_id': 7,
    'store_name': 'Mazaq',
  },
};

void main() {
  group('CartLineModel.cartFromJson', () {
    test('reads each line with the nested item details', () {
      final Cart cart = CartLineModel.cartFromJson(<dynamic>[_lineJson()]);

      expect(
        cart.lines.single.props,
        const CartLine(
          id: 11,
          itemId: 3,
          name: 'SSM Burger Meal',
          imageUrl: 'https://cdn.example.com/i/3.png',
          unitPrice: 12.5,
          quantity: 2,
          storeId: 7,
          storeName: 'Mazaq',
        ).props,
      );
    });

    test('skips lines without an id, a price or a positive quantity', () {
      final Cart cart = CartLineModel.cartFromJson(<dynamic>[
        _lineJson(id: null),
        _lineJson(price: null),
        _lineJson(quantity: 0),
        _lineJson(),
      ]);

      expect(cart.lines, hasLength(1));
    });

    test('throws ServerException when the body is not a list', () {
      expect(
        () => CartLineModel.cartFromJson(<String, dynamic>{}),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('CartRemoteDataSource', () {
    late FakeDioConsumer consumer;
    late CartRemoteDataSourceImpl remote;

    setUp(() {
      consumer = FakeDioConsumer(response: <dynamic>[_lineJson()]);
      remote = CartRemoteDataSourceImpl(consumer: consumer);
    });

    test('adding posts the item, its model, quantity and price', () async {
      final Cart cart = await remote.addItem(
        itemId: 3,
        unitPrice: 12.5,
        quantity: 1,
      );

      expect(consumer.lastPath, ApiEndpoints.cartAdd);
      expect(consumer.lastBody, <String, dynamic>{
        'item_id': 3,
        'model': 'Item',
        'quantity': 1,
        'price': 12.5,
      });
      expect(cart.lines, hasLength(1));
    });

    test('an update posts the cart line id and new quantity', () async {
      await remote.updateQuantity(cartLineId: 11, quantity: 3);

      expect(consumer.lastVerb, 'POST');
      expect(consumer.lastPath, ApiEndpoints.cartUpdate);
      expect(consumer.lastBody, <String, dynamic>{
        'cart_id': 11,
        'quantity': 3,
      });
    });

    test('removing sends the cart line id in a DELETE body', () async {
      await remote.removeLine(11);

      expect(consumer.lastVerb, 'DELETE');
      expect(consumer.lastPath, ApiEndpoints.cartRemoveItem);
      expect(consumer.lastBody, <String, dynamic>{'cart_id': 11});
    });

    test('a change answering without the cart refetches it', () async {
      consumer.response = <String, dynamic>{'message': 'updated'};

      // The fake answers the refetch with the same body, so it fails to
      // parse — proving the list was requested rather than guessed at.
      await expectLater(
        remote.updateQuantity(cartLineId: 11, quantity: 3),
        throwsA(isA<ServerException>()),
      );
      expect(consumer.lastVerb, 'GET');
      expect(consumer.lastPath, ApiEndpoints.cartList);
    });
  });

  group('CartRepositoryImpl', () {
    late FakeDioConsumer consumer;
    late _FakeZoneRepository zone;
    late CartRepositoryImpl repository;

    setUp(() {
      consumer = FakeDioConsumer(response: <dynamic>[]);
      zone = _FakeZoneRepository();
      repository = CartRepositoryImpl(
        remote: CartRemoteDataSourceImpl(consumer: consumer),
        zoneRepository: zone,
      );
    });

    test('an unknown cart line maps to NotFoundFailure', () async {
      consumer.error = const NotFoundException(message: 'Not found');

      final Either<Failure, Cart> result = await repository.updateQuantity(
        cartLineId: 999999,
        quantity: 1,
      );

      expect(
        result,
        const Left<Failure, Cart>(NotFoundFailure(message: 'Not found')),
      );
    });

    test('without a zone, fails without calling the cart', () async {
      zone.answer = const Left<Failure, List<int>>(ZoneUnavailableFailure());

      final Either<Failure, Cart> result = await repository.getCart();

      expect(result, const Left<Failure, Cart>(ZoneUnavailableFailure()));
      expect(consumer.lastPath, isNull);
    });
  });
}
