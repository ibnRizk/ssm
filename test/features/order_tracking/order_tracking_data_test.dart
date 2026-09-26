import 'package:dartz/dartz.dart';
import 'package:flutter_base/core/api/api_endpoints.dart';
import 'package:flutter_base/core/error/exceptions.dart';
import 'package:flutter_base/core/error/failures.dart';
import 'package:flutter_base/core/location/geo_point.dart';
import 'package:flutter_base/core/zone/zone_repository.dart';
import 'package:flutter_base/features/order_tracking/data/datasources/order_tracking_remote_data_source.dart';
import 'package:flutter_base/features/order_tracking/data/models/order_tracking_models.dart';
import 'package:flutter_base/features/order_tracking/data/repos/order_tracking_repository_impl.dart';
import 'package:flutter_base/features/order_tracking/domain/entities/order_status.dart';
import 'package:flutter_base/features/order_tracking/domain/entities/order_tracking.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_dio_consumer.dart';

class _FakeZoneRepository implements ZoneRepository {
  @override
  Future<Either<Failure, List<int>>> ensureZoneIds() async =>
      const Right<Failure, List<int>>(<int>[1]);

  @override
  Future<Either<Failure, Unit>> selectZoneIds(List<int> zoneIds) =>
      throw UnimplementedError();
}

void main() {
  group('OrderTrackingModels.summaryFromJson', () {
    test('reads the legacy status, amounts and store', () {
      expect(
        OrderTrackingModels.summaryFromJson(<String, dynamic>{
          'id': 100045,
          'order_status': 'pending',
          'order_amount': '57.50',
          'delivery_charge': 10,
          'store': <String, dynamic>{'name': 'Mazaq', 'phone': '+966500000000'},
        }),
        const OrderSummary(
          id: 100045,
          legacyStatus: 'pending',
          orderAmount: 57.5,
          deliveryCharge: 10,
          storeName: 'Mazaq',
          storePhone: '+966500000000',
        ),
      );
    });

    test('throws ServerException without an id', () {
      expect(
        () => OrderTrackingModels.summaryFromJson(<String, dynamic>{}),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('OrderTrackingModels.linesFromJson', () {
    test('reads item_details as a map or as a JSON string', () {
      expect(
        OrderTrackingModels.linesFromJson(<dynamic>[
          <String, dynamic>{
            'quantity': 2,
            'price': '20',
            'item_details': <String, dynamic>{'name': 'Burger'},
          },
          <String, dynamic>{
            'quantity': '1',
            'price': 5.5,
            'item_details': '{"name":"Fries"}',
          },
        ]),
        const <OrderLine>[
          OrderLine(name: 'Burger', quantity: 2, unitPrice: 20),
          OrderLine(name: 'Fries', quantity: 1, unitPrice: 5.5),
        ],
      );
    });

    test('skips lines without a name, quantity or price', () {
      expect(
        OrderTrackingModels.linesFromJson(<dynamic>[
          <String, dynamic>{'quantity': 1, 'price': 1, 'item_details': '{'},
          <String, dynamic>{
            'quantity': 0,
            'price': 1,
            'item_details': <String, dynamic>{'name': 'x'},
          },
          <String, dynamic>{
            'quantity': 1,
            'item_details': <String, dynamic>{'name': 'x'},
          },
        ]),
        isEmpty,
      );
    });

    test('throws ServerException when the body is not a list', () {
      expect(
        () => OrderTrackingModels.linesFromJson(<String, dynamic>{}),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('OrderTrackingModels.trackingFromJson', () {
    test('reads the canonical status, driver and location', () {
      expect(
        OrderTrackingModels.trackingFromJson(<String, dynamic>{
          'order_id': 9,
          'ssm_status': 'out_for_delivery',
          'tracking_allowed': true,
          'driver': <String, dynamic>{'id': 3, 'name': 'Omar'},
          'location': <String, dynamic>{
            'latitude': '24.7',
            'longitude': 46.6,
            'is_fresh': false,
          },
        }),
        const OrderTracking(
          orderId: 9,
          status: OrderStatus.outForDelivery,
          trackingAllowed: true,
          driverName: 'Omar',
          location: DriverLocation(
            point: GeoPoint(latitude: 24.7, longitude: 46.6),
            isFresh: false,
          ),
        ),
      );
    });

    test('a null ssm_status (merchant not acted yet) stays null', () {
      final OrderTracking tracking =
          OrderTrackingModels.trackingFromJson(<String, dynamic>{
            'order_id': 9,
            'ssm_status': null,
            'tracking_allowed': false,
            'driver': null,
            'location': null,
          });

      expect(tracking.status, isNull);
      expect(tracking.driverName, isNull);
      expect(tracking.location, isNull);
    });

    test('knows every canonical status', () {
      const Map<String, OrderStatus> wire = <String, OrderStatus>{
        'pending_merchant': OrderStatus.pendingMerchant,
        'accepted': OrderStatus.accepted,
        'preparing': OrderStatus.preparing,
        'ready_for_pickup': OrderStatus.readyForPickup,
        'dispatching': OrderStatus.dispatching,
        'driver_assigned': OrderStatus.driverAssigned,
        'driver_accepted': OrderStatus.driverAccepted,
        'picked_up': OrderStatus.pickedUp,
        'out_for_delivery': OrderStatus.outForDelivery,
        'delivered': OrderStatus.delivered,
        'rejected': OrderStatus.rejected,
        'cancelled': OrderStatus.cancelled,
        'assignment_failed': OrderStatus.assignmentFailed,
      };
      for (final MapEntry<String, OrderStatus> e in wire.entries) {
        expect(OrderTrackingModels.statusFromWire(e.key), e.value);
      }
      expect(wire.values.toSet(), OrderStatus.values.toSet());
      expect(OrderTrackingModels.statusFromWire('teleported'), isNull);
    });
  });

  group('OrderTrackingModels.deliveryOtpFromJson', () {
    test('reads the code and its expiry', () {
      expect(
        OrderTrackingModels.deliveryOtpFromJson(<String, dynamic>{
          'delivery_otp': <String, dynamic>{
            'challenge_id': 'c1',
            'otp': '048213',
            'expires_at': '2026-09-26T12:30:00Z',
          },
        }),
        DeliveryOtp(
          code: '048213',
          expiresAt: DateTime.utc(2026, 9, 26, 12, 30),
        ),
      );
    });

    test('a numeric code keeps its leading zeros', () {
      expect(
        OrderTrackingModels.deliveryOtpFromJson(<String, dynamic>{
          'delivery_otp': <String, dynamic>{'otp': 48213},
        }).code,
        '048213',
      );
    });

    test('throws ServerException without a code', () {
      expect(
        () => OrderTrackingModels.deliveryOtpFromJson(<String, dynamic>{
          'delivery_otp': <String, dynamic>{},
        }),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('OrderTrackingRepositoryImpl', () {
    late FakeDioConsumer consumer;
    late OrderTrackingRepositoryImpl repository;

    setUp(() {
      consumer = FakeDioConsumer();
      repository = OrderTrackingRepositoryImpl(
        remote: OrderTrackingRemoteDataSourceImpl(consumer: consumer),
        zoneRepository: _FakeZoneRepository(),
      );
    });

    test('the legacy endpoints take the id as order_id', () async {
      consumer.response = <String, dynamic>{'id': 9};
      await repository.getSummary(9);
      expect(consumer.lastPath, ApiEndpoints.orderTrack);
      expect(consumer.lastQuery, <String, dynamic>{'order_id': 9});

      consumer.response = <dynamic>[];
      await repository.getLines(9);
      expect(consumer.lastPath, ApiEndpoints.orderDetails);
      expect(consumer.lastQuery, <String, dynamic>{'order_id': 9});
    });

    test('tracking and the OTP take the id in the path', () async {
      consumer.response = <String, dynamic>{'order_id': 9};
      await repository.getTracking(9);
      expect(consumer.lastPath, '/api/v1/customer/orders/9/tracking');

      consumer.response = <String, dynamic>{
        'delivery_otp': <String, dynamic>{'otp': '123456'},
      };
      await repository.requestDeliveryOtp(9);
      expect(consumer.lastVerb, 'POST');
      expect(
        consumer.lastPath,
        '/api/v1/customer/orders/9/delivery-otp/request',
      );
    });

    test('an OTP before out-for-delivery is a ConflictFailure', () async {
      consumer.error = const ConflictException(
        message: 'Not available',
        code: 'otp-not-available',
      );

      expect(
        await repository.requestDeliveryOtp(9),
        const Left<Failure, DeliveryOtp>(
          ConflictFailure(message: 'Not available', code: 'otp-not-available'),
        ),
      );
    });
  });
}
