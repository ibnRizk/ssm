import 'package:dartz/dartz.dart';
import 'package:flutter_base/core/api/api_endpoints.dart';
import 'package:flutter_base/core/error/exceptions.dart';
import 'package:flutter_base/core/error/failures.dart';
import 'package:flutter_base/core/location/geo_point.dart';
import 'package:flutter_base/core/zone/zone_repository.dart';
import 'package:flutter_base/features/checkout/data/datasources/checkout_remote_data_source.dart';
import 'package:flutter_base/features/checkout/data/models/placed_order_model.dart';
import 'package:flutter_base/features/checkout/data/models/requests/place_order_body.dart';
import 'package:flutter_base/features/checkout/data/repos/checkout_repository_impl.dart';
import 'package:flutter_base/features/checkout/domain/entities/order_request.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_dio_consumer.dart';

class _FakeZoneRepository implements ZoneRepository {
  final List<List<int>> selected = <List<int>>[];
  Either<Failure, Unit> selectAnswer = const Right<Failure, Unit>(unit);

  @override
  Future<Either<Failure, List<int>>> ensureZoneIds() async =>
      Right<Failure, List<int>>(selected.lastOrNull ?? <int>[1]);

  @override
  Future<Either<Failure, Unit>> selectZoneIds(List<int> zoneIds) async {
    selected.add(zoneIds);
    return selectAnswer;
  }
}

const OrderRequest _request = OrderRequest(
  storeId: 7,
  orderAmount: 42.5,
  deliveryAddress: 'Olaya St 12, Riyadh',
  location: GeoPoint(latitude: 24.71, longitude: 46.68),
  contactPersonName: 'Sara Customer',
  contactPersonNumber: '+966512345678',
  zoneId: 2,
);

Map<String, dynamic> _refusal(String code, String message) => <String, dynamic>{
  'errors': <Map<String, String>>[
    <String, String>{'code': code, 'message': message},
  ],
};

void main() {
  group('PlaceOrderBody', () {
    test('is a cash-on-delivery delivery order for the address', () {
      expect(const PlaceOrderBody(_request).toJson(), <String, dynamic>{
        'order_type': 'delivery',
        'payment_method': 'cash_on_delivery',
        'store_id': 7,
        'order_amount': 42.5,
        'distance': 0,
        'address': 'Olaya St 12, Riyadh',
        'latitude': '24.71',
        'longitude': '46.68',
        'contact_person_name': 'Sara Customer',
        'contact_person_number': '+966512345678',
      });
    });
  });

  group('PlacedOrderModel.fromJson', () {
    test('reads the order id and the misspelled total_ammount', () {
      final PlacedOrderModel order =
          PlacedOrderModel.fromJson(<String, dynamic>{
            'message': 'Order placed successfully!',
            'order_id': 100045,
            'total_ammount': '57.50',
            'status': 'pending',
          });

      expect(order.id, 100045);
      expect(order.totalAmount, 57.5);
    });

    // A 203 is a success status to Dio, so the refusal arrives as a body.
    test('a 203 refusal body throws ForbiddenException with its code', () {
      expect(
        () => PlacedOrderModel.fromJson(
          _refusal('order_amount', 'Amount crossed maximum cod order amount'),
        ),
        throwsA(
          const ForbiddenException(
            message: 'Amount crossed maximum cod order amount',
            code: 'order_amount',
          ),
        ),
      );
    });

    test('throws ServerException without an order id', () {
      expect(
        () => PlacedOrderModel.fromJson(<String, dynamic>{'message': 'ok'}),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('CheckoutRepositoryImpl.placeOrder', () {
    late FakeDioConsumer consumer;
    late _FakeZoneRepository zone;
    late CheckoutRepositoryImpl repository;

    setUp(() {
      consumer = FakeDioConsumer(
        response: <String, dynamic>{'order_id': 9, 'total_ammount': 52.5},
      );
      zone = _FakeZoneRepository();
      repository = CheckoutRepositoryImpl(
        remote: CheckoutRemoteDataSourceImpl(consumer: consumer),
        zoneRepository: zone,
      );
    });

    test('switches to the address zone, then posts the order', () async {
      final Either<Failure, PlacedOrder> result = await repository.placeOrder(
        _request,
      );

      expect(zone.selected, <List<int>>[
        <int>[2],
      ]);
      expect(consumer.lastPath, ApiEndpoints.orderPlace);
      expect(consumer.lastBody, const PlaceOrderBody(_request).toJson());
      expect(
        result.fold((_) => null, (PlacedOrder o) => o.props),
        const PlacedOrder(id: 9, totalAmount: 52.5).props,
      );
    });

    test('a 203 refusal becomes a ForbiddenFailure', () async {
      consumer.response = _refusal('order_amount', 'Too much');

      final Either<Failure, PlacedOrder> result = await repository.placeOrder(
        _request,
      );

      expect(
        result,
        const Left<Failure, PlacedOrder>(
          ForbiddenFailure(message: 'Too much', code: 'order_amount'),
        ),
      );
    });

    test('a 403 out-of-zone refusal keeps its code', () async {
      consumer.error = const ForbiddenException(
        message: 'Out of coverage!',
        code: 'coordinates',
      );

      final Either<Failure, PlacedOrder> result = await repository.placeOrder(
        _request,
      );

      expect(
        result,
        const Left<Failure, PlacedOrder>(
          ForbiddenFailure(message: 'Out of coverage!', code: 'coordinates'),
        ),
      );
    });

    test('a zone that cannot be saved stops the order', () async {
      zone.selectAnswer = const Left<Failure, Unit>(CacheFailure());

      final Either<Failure, PlacedOrder> result = await repository.placeOrder(
        _request,
      );

      expect(result, const Left<Failure, PlacedOrder>(CacheFailure()));
      expect(consumer.lastPath, isNull);
    });
  });
}
