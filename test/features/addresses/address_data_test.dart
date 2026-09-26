import 'package:dartz/dartz.dart';
import 'package:flutter_base/core/api/api_endpoints.dart';
import 'package:flutter_base/core/error/exceptions.dart';
import 'package:flutter_base/core/error/failures.dart';
import 'package:flutter_base/features/addresses/data/datasources/address_remote_data_source.dart';
import 'package:flutter_base/features/addresses/data/datasources/device_location_data_source.dart';
import 'package:flutter_base/features/addresses/data/models/address_model.dart';
import 'package:flutter_base/features/addresses/data/repos/address_repository_impl.dart';
import 'package:flutter_base/features/addresses/data/repos/location_repository_impl.dart';
import 'package:flutter_base/features/addresses/domain/entities/address.dart';
import 'package:flutter_base/features/addresses/domain/repos/address_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_dio_consumer.dart';

const NewAddress _newAddress = NewAddress(
  type: AddressType.home,
  contactPersonName: 'Sara Customer',
  contactPersonNumber: '+966512345678',
  address: 'Olaya St 12, Riyadh',
  location: GeoPoint(latitude: 24.71, longitude: 46.68),
);

class _FakeDevice implements DeviceLocationDataSource {
  Object? error;

  @override
  Future<GeoPoint> getCurrentLocation() async {
    if (error case final Object e) throw e;
    return const GeoPoint(latitude: 1, longitude: 2);
  }
}

void main() {
  group('AddressModel.listFromJson', () {
    test('reads the addresses envelope, coordinates as strings', () {
      final List<AddressModel> addresses = AddressModel.listFromJson(
        <String, dynamic>{
          'addresses': <dynamic>[
            <String, dynamic>{
              'id': 12,
              'user_id': 7,
              'address_type': 'home',
              'contact_person_name': 'Sara Customer',
              'contact_person_number': '+966512345678',
              'address': 'Olaya St 12, Riyadh',
              'latitude': '24.7100',
              'longitude': '46.6800',
            },
          ],
        },
      );

      expect(
        addresses.single.props,
        const Address(
          id: 12,
          type: AddressType.home,
          contactPersonName: 'Sara Customer',
          contactPersonNumber: '+966512345678',
          address: 'Olaya St 12, Riyadh',
          location: GeoPoint(latitude: 24.71, longitude: 46.68),
        ).props,
      );
    });

    test('skips entries without an id or address text', () {
      final List<AddressModel> addresses = AddressModel.listFromJson(
        <String, dynamic>{
          'addresses': <dynamic>[
            <String, dynamic>{'address': 'No id'},
            <String, dynamic>{'id': 3},
            <String, dynamic>{'id': '4', 'address': 'Kept'},
          ],
        },
      );

      expect(addresses.map((Address a) => a.id), <int>[4]);
    });

    test('keeps an entry with unusable coordinates, without a location', () {
      final List<AddressModel> addresses = AddressModel.listFromJson(
        <String, dynamic>{
          'addresses': <dynamic>[
            <String, dynamic>{'id': 1, 'address': 'x', 'latitude': 'n/a'},
          ],
        },
      );

      expect(addresses.single.location, isNull);
    });

    test('reads unknown address types as other', () {
      expect(AddressModel.addressTypeFromWire('others'), AddressType.other);
      expect(AddressModel.addressTypeFromWire('OFFICE'), AddressType.office);
      expect(AddressModel.addressTypeFromWire(null), AddressType.other);
    });

    test('throws ServerException without an addresses list', () {
      expect(
        () => AddressModel.listFromJson(<String, dynamic>{'data': <dynamic>[]}),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('AddressRemoteDataSource', () {
    test('add posts every field the API requires', () async {
      final FakeDioConsumer consumer = FakeDioConsumer();

      await AddressRepositoryImpl(
        remote: AddressRemoteDataSourceImpl(consumer: consumer),
      ).addAddress(_newAddress);

      expect(consumer.lastPath, ApiEndpoints.addressAdd);
      expect(consumer.lastBody, <String, dynamic>{
        'address_type': 'home',
        'contact_person_name': 'Sara Customer',
        'contact_person_number': '+966512345678',
        'address': 'Olaya St 12, Riyadh',
        'latitude': '24.7100000',
        'longitude': '46.6800000',
      });
    });

    test('delete sends the id as the address_id query parameter', () async {
      final FakeDioConsumer consumer = FakeDioConsumer();

      await AddressRemoteDataSourceImpl(consumer: consumer).deleteAddress(12);

      expect(consumer.lastVerb, 'DELETE');
      expect(consumer.lastPath, ApiEndpoints.addressDelete);
      expect(consumer.lastQuery, <String, dynamic>{'address_id': 12});
    });
  });

  group('repositories', () {
    test('an out-of-coverage 403 keeps its coordinates code', () async {
      final FakeDioConsumer consumer = FakeDioConsumer()
        ..error = const ForbiddenException(
          message: 'Out of coverage!',
          code: outOfCoverageCode,
        );

      final Either<Failure, Unit> result = await AddressRepositoryImpl(
        remote: AddressRemoteDataSourceImpl(consumer: consumer),
      ).addAddress(_newAddress);

      expect(
        result,
        const Left<Failure, Unit>(
          ForbiddenFailure(
            message: 'Out of coverage!',
            code: outOfCoverageCode,
          ),
        ),
      );
    });

    test('a denied location permission maps to LocationFailure', () async {
      final _FakeDevice device = _FakeDevice()
        ..error = const LocationException(
          reason: LocationFailureReason.permissionDenied,
        );

      final Either<Failure, GeoPoint> result = await LocationRepositoryImpl(
        device: device,
      ).getCurrentLocation();

      expect(
        result,
        const Left<Failure, GeoPoint>(
          LocationFailure(reason: LocationFailureReason.permissionDenied),
        ),
      );
    });
  });
}
