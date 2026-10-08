import 'package:dartz/dartz.dart';
import 'package:ssm/core/api/api_endpoints.dart';
import 'package:ssm/core/delivery_otp/delivery_otp.dart';
import 'package:ssm/core/error/exceptions.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/core/location/geo_point.dart';
import 'package:ssm/features/parcels/data/datasources/parcels_remote_data_source.dart';
import 'package:ssm/features/parcels/data/models/parcel_model.dart';
import 'package:ssm/features/parcels/data/repos/parcels_repository_impl.dart';
import 'package:ssm/features/parcels/domain/entities/parcel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_dio_consumer.dart';

Parcel _parcel(int id, ParcelStatus status, {GeoPoint? dropoff}) => Parcel(
  id: id,
  reference: 'SSM-P$id',
  status: status,
  paymentType: ParcelPaymentType.prepaid,
  codAmount: 0,
  deliveryFee: 0,
  currency: 'SAR',
  dropoffLocation: dropoff,
);

const GeoPoint _point = GeoPoint(latitude: 24.705, longitude: 46.69);

void main() {
  group('ParcelModel.listFromJson', () {
    test('maps a COD parcel', () {
      final Parcel parcel = ParcelModel.listFromJson(<String, dynamic>{
        'data': <dynamic>[
          <String, dynamic>{
            'id': 2048,
            'tracking_number': 'SSM-P2048',
            'status': 'at_warehouse',
            'payment_type': 'COD',
            'cod_amount': '45.50',
            'customer_delivery_fee': '0.00',
            'customer_delivery_fee_currency': 'SAR',
            'latitude': '24.705',
            'longitude': 46.69,
            'delivery_address': 'Al Malaz, gate 2',
          },
        ],
        'total_size': 1,
      }).single;

      expect(parcel.reference, 'SSM-P2048');
      expect(parcel.status, ParcelStatus.atWarehouse);
      expect(parcel.paymentType, ParcelPaymentType.cod);
      expect(parcel.codAmount, 45.5);
      expect(parcel.deliveryFee, 0);
      expect(parcel.dropoffLocation, _point);
      expect(parcel.deliveryAddress, 'Al Malaz, gate 2');
    });

    test('a prepaid parcel without a drop-off or reference', () {
      final Parcel parcel = ParcelModel.listFromJson(<String, dynamic>{
        'data': <dynamic>[
          <String, dynamic>{'id': 7, 'payment_type': 'PREPAID'},
        ],
      }).single;

      expect(parcel.reference, '#7');
      expect(parcel.paymentType, ParcelPaymentType.prepaid);
      expect(parcel.codAmount, 0);
      expect(parcel.hasDropoffLocation, isFalse);
    });

    test('reads updated_at, and tolerates a missing or garbled one', () {
      final List<ParcelModel> list = ParcelModel.listFromJson(<String, dynamic>{
        'data': <dynamic>[
          <String, dynamic>{
            'id': 1,
            'updated_at': '2026-09-26T08:30:00.000000Z',
          },
          <String, dynamic>{'id': 2},
          <String, dynamic>{'id': 3, 'updated_at': 'yesterday'},
        ],
      });

      expect(list[0].updatedAt, DateTime.utc(2026, 9, 26, 8, 30));
      expect(list[1].updatedAt, isNull);
      expect(list[2].updatedAt, isNull);
    });

    test('skips entries without an id', () {
      expect(
        ParcelModel.listFromJson(<String, dynamic>{
          'data': <dynamic>[
            <String, dynamic>{'status': 'delivered'},
          ],
        }),
        isEmpty,
      );
    });

    test('throws ServerException without a data list', () {
      expect(
        () => ParcelModel.listFromJson(<dynamic>[]),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('ParcelModel.statusFromWire', () {
    test('maps each stage', () {
      expect(ParcelModel.statusFromWire('received'), ParcelStatus.atWarehouse);
      expect(
        ParcelModel.statusFromWire('OUT_FOR_DELIVERY'),
        ParcelStatus.outForDelivery,
      );
      expect(
        ParcelModel.statusFromWire('picked_up'),
        ParcelStatus.outForDelivery,
      );
      expect(ParcelModel.statusFromWire('delivered'), ParcelStatus.delivered);
    });

    test('never guesses a later stage for an unknown value', () {
      expect(ParcelModel.statusFromWire('mystery'), ParcelStatus.processing);
      expect(ParcelModel.statusFromWire(null), ParcelStatus.processing);
    });
  });

  group('Parcel.dropoffTarget', () {
    test('prefers a warehouse parcel still waiting for a location', () {
      expect(
        Parcel.dropoffTarget(<Parcel>[
          _parcel(1, ParcelStatus.atWarehouse, dropoff: _point),
          _parcel(2, ParcelStatus.atWarehouse),
        ])?.id,
        2,
      );
    });

    test('falls back to a warehouse parcel that already has one', () {
      expect(
        Parcel.dropoffTarget(<Parcel>[
          _parcel(1, ParcelStatus.processing),
          _parcel(2, ParcelStatus.atWarehouse, dropoff: _point),
        ])?.id,
        2,
      );
    });

    test('is null when nothing is at the warehouse', () {
      expect(
        Parcel.dropoffTarget(<Parcel>[
          _parcel(1, ParcelStatus.processing),
          _parcel(2, ParcelStatus.delivered),
        ]),
        isNull,
      );
    });
  });

  group('POST /customer/parcels/{id}/location', () {
    test('sends coordinates as numbers, address and notes', () async {
      final FakeDioConsumer consumer = FakeDioConsumer();

      await ParcelsRemoteDataSourceImpl(consumer: consumer).sendDropoff(
        2048,
        const ParcelDropoff(
          location: _point,
          deliveryAddress: 'Al Malaz, gate 2',
          notes: 'Call on arrival',
        ),
      );

      expect(consumer.lastPath, ApiEndpoints.parcelLocation(2048));
      expect(consumer.lastBody, <String, dynamic>{
        'latitude': 24.705,
        'longitude': 46.69,
        'delivery_address': 'Al Malaz, gate 2',
        'notes': 'Call on arrival',
      });
    });

    test('leaves out empty notes', () async {
      final FakeDioConsumer consumer = FakeDioConsumer();

      await ParcelsRemoteDataSourceImpl(consumer: consumer).sendDropoff(
        1,
        const ParcelDropoff(location: _point, deliveryAddress: 'x', notes: ''),
      );

      expect(consumer.lastBody!.containsKey('notes'), isFalse);
    });

    test('a 422 refusal maps to a failure with its message', () async {
      final FakeDioConsumer consumer = FakeDioConsumer()
        ..error = const ServerException(
          message: 'The parcel has already been delivered.',
        );

      final Either<Failure, Unit> result =
          await ParcelsRepositoryImpl(
            remote: ParcelsRemoteDataSourceImpl(consumer: consumer),
          ).sendDropoff(
            1,
            const ParcelDropoff(location: _point, deliveryAddress: 'x'),
          );

      expect(
        result,
        const Left<Failure, Unit>(
          ServerFailure(message: 'The parcel has already been delivered.'),
        ),
      );
    });
  });

  group('POST /customer/parcels/{id}/delivery-otp/request', () {
    test('posts to the parcel and keeps leading zeros', () async {
      final FakeDioConsumer consumer = FakeDioConsumer(
        response: <String, dynamic>{
          'delivery_otp': <String, dynamic>{
            'otp': 42913,
            'expires_at': '2026-10-06T12:30:00Z',
          },
        },
      );

      final DeliveryOtp otp = await ParcelsRemoteDataSourceImpl(
        consumer: consumer,
      ).requestDeliveryOtp(3001);

      expect(consumer.lastPath, ApiEndpoints.parcelDeliveryOtpRequest(3001));
      expect(
        otp,
        DeliveryOtp(
          code: '042913',
          expiresAt: DateTime.utc(2026, 10, 6, 12, 30),
        ),
      );
    });

    test('a 409 maps to a ConflictFailure', () async {
      final FakeDioConsumer consumer = FakeDioConsumer()
        ..error = const ConflictException(code: 'otp-not-available');

      final Either<Failure, DeliveryOtp> result = await ParcelsRepositoryImpl(
        remote: ParcelsRemoteDataSourceImpl(consumer: consumer),
      ).requestDeliveryOtp(3001);

      expect(
        result.fold((Failure f) => f, (_) => null),
        isA<ConflictFailure>(),
      );
    });
  });

  group('POST /customer/parcels/{id}/delivery-otp/request', () {
    test('posts to the parcel path and parses the code', () async {
      final FakeDioConsumer consumer = FakeDioConsumer(
        response: <String, dynamic>{
          'delivery_otp': <String, dynamic>{
            'otp': '048213',
            'expires_at': '2026-10-08T12:30:00Z',
          },
        },
      );

      final DeliveryOtp otp = await ParcelsRemoteDataSourceImpl(
        consumer: consumer,
      ).requestDeliveryOtp(2048);

      expect(consumer.lastVerb, 'POST');
      expect(
        consumer.lastPath,
        '/api/v1/customer/parcels/2048/delivery-otp/request',
      );
      expect(otp.code, '048213');
      expect(otp.expiresAt, DateTime.utc(2026, 10, 8, 12, 30));
    });

    test('a 409 before out-for-delivery maps to a ConflictFailure', () async {
      final FakeDioConsumer consumer = FakeDioConsumer()
        ..error = const ConflictException(
          message: 'Not available',
          code: 'otp-not-available',
        );

      final Either<Failure, DeliveryOtp> result = await ParcelsRepositoryImpl(
        remote: ParcelsRemoteDataSourceImpl(consumer: consumer),
      ).requestDeliveryOtp(2048);

      expect(
        result.fold((Failure f) => f, (_) => null),
        isA<ConflictFailure>(),
      );
    });
  });
}
