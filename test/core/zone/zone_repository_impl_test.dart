import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:ssm/core/api/api_endpoints.dart';
import 'package:ssm/core/error/exceptions.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/core/location/device_location_data_source.dart';
import 'package:ssm/core/location/geo_point.dart';
import 'package:ssm/core/services/local_storage/app_shared_preferences.dart';
import 'package:ssm/core/zone/zone_remote_data_source.dart';
import 'package:ssm/core/zone/zone_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_dio_consumer.dart';

class _FakeZoneRemote implements ZoneRemoteDataSource {
  List<int> addressZones = const <int>[];
  List<int> zonesHere = const <int>[];
  int? serviceZoneId;
  Object? error;
  Object? zoneHereError;

  /// When set, [addressZoneIds] waits on it — lets a test hold the
  /// resolution open to issue a concurrent call.
  Completer<void>? gate;

  int addressCalls = 0;
  int serviceCalls = 0;
  GeoPoint? askedAt;

  @override
  Future<List<int>> addressZoneIds() async {
    addressCalls++;
    await gate?.future;
    if (error case final Object e) throw e;
    return addressZones;
  }

  @override
  Future<List<int>> zoneIdsAt(GeoPoint point) async {
    askedAt = point;
    if (zoneHereError case final Object e) throw e;
    return zonesHere;
  }

  @override
  Future<int?> firstServiceZoneId() async {
    serviceCalls++;
    return serviceZoneId;
  }
}

class _FakeLocation implements DeviceLocationDataSource {
  /// Null means no fix — permission denied, GPS off.
  GeoPoint? point;
  int calls = 0;

  @override
  Future<GeoPoint> getCurrentLocation() async {
    calls++;
    return point ??
        (throw const LocationException(
          reason: LocationFailureReason.permissionDenied,
        ));
  }
}

/// Storage that refuses to save a zone.
class _FailingPreferences extends AppSharedPreferencesImpl {
  _FailingPreferences({required super.instance});

  @override
  Future<bool> saveZoneIds(List<int> ids) async => throw Exception('disk full');
}

const GeoPoint _cairo = GeoPoint(latitude: 30.0463, longitude: 31.3715);

void main() {
  late _FakeZoneRemote remote;
  late _FakeLocation location;
  late AppSharedPreferences preferences;
  late ZoneRepositoryImpl repository;

  Future<void> setUpWith(Map<String, Object> stored) async {
    SharedPreferences.setMockInitialValues(stored);
    preferences = AppSharedPreferencesImpl(
      instance: await SharedPreferences.getInstance(),
    );
    remote = _FakeZoneRemote();
    location = _FakeLocation();
    repository = ZoneRepositoryImpl(
      remote: remote,
      location: location,
      preferences: preferences,
    );
  }

  List<int> zoneOf(Either<Failure, List<int>> result) =>
      result.getOrElse(() => <int>[]);

  group('ensureZoneIds', () {
    test('replaces a stale saved zone on the first call of a launch', () async {
      await setUpWith(<String, Object>{
        'zoneIds': <String>['7'],
      });
      remote.addressZones = <int>[8];

      expect(zoneOf(await repository.ensureZoneIds()), <int>[8]);
      expect(preferences.getZoneIds(), <int>[8]);
    });

    test('later calls of the launch use the saved zone', () async {
      await setUpWith(<String, Object>{});
      remote.addressZones = <int>[8];
      await repository.ensureZoneIds();

      expect(zoneOf(await repository.ensureZoneIds()), <int>[8]);
      expect(remote.addressCalls, 1);
    });

    test('keeps a saved zone that is one of the address zones', () async {
      await setUpWith(<String, Object>{
        'zoneIds': <String>['5'],
      });
      remote.addressZones = <int>[2, 5];

      expect(zoneOf(await repository.ensureZoneIds()), <int>[5]);
    });

    test('uses the first address zone without asking for a location', () async {
      await setUpWith(<String, Object>{});
      remote.addressZones = <int>[2, 9];

      expect(zoneOf(await repository.ensureZoneIds()), <int>[2]);
      expect(location.calls, 0);
    });

    test('without an address, uses the zone at the device location', () async {
      await setUpWith(<String, Object>{});
      location.point = _cairo;
      remote
        ..zonesHere = <int>[8]
        ..serviceZoneId = 7;

      expect(zoneOf(await repository.ensureZoneIds()), <int>[8]);
      expect(remote.askedAt, _cairo);
      expect(remote.serviceCalls, 0);
    });

    test('without a location fix, keeps the saved zone', () async {
      await setUpWith(<String, Object>{
        'zoneIds': <String>['3'],
      });
      remote.serviceZoneId = 1;

      expect(zoneOf(await repository.ensureZoneIds()), <int>[3]);
      expect(remote.serviceCalls, 0);
    });

    test('without a location fix or a saved zone, falls back to the first '
        'service zone', () async {
      await setUpWith(<String, Object>{});
      remote.serviceZoneId = 1;

      expect(zoneOf(await repository.ensureZoneIds()), <int>[1]);
      expect(preferences.getZoneIds(), <int>[1]);
    });

    test('outside every zone is a ZoneUnavailableFailure', () async {
      await setUpWith(<String, Object>{});
      location.point = _cairo;
      remote.zoneHereError = const NotFoundException(
        message: 'Service not available in this area',
      );

      expect(
        await repository.ensureZoneIds(),
        const Left<Failure, List<int>>(
          ZoneUnavailableFailure(message: 'Service not available in this area'),
        ),
      );
      expect(preferences.getZoneIds(), isEmpty);
    });

    test('is a ZoneUnavailableFailure when there is no zone at all', () async {
      await setUpWith(<String, Object>{});

      expect(
        await repository.ensureZoneIds(),
        const Left<Failure, List<int>>(ZoneUnavailableFailure()),
      );
      expect(preferences.getZoneIds(), isEmpty);
    });

    test('offline, keeps the saved zone and resolves on the next call', () async {
      await setUpWith(<String, Object>{
        'zoneIds': <String>['3'],
      });
      remote.error = const InternetConnectionException(message: 'offline');

      expect(zoneOf(await repository.ensureZoneIds()), <int>[3]);

      remote
        ..error = null
        ..addressZones = <int>[4];
      expect(zoneOf(await repository.ensureZoneIds()), <int>[4]);
    });

    test('without a saved zone, a network error is a failure', () async {
      await setUpWith(<String, Object>{});
      remote.error = const InternetConnectionException(message: 'offline');

      expect(
        await repository.ensureZoneIds(),
        const Left<Failure, List<int>>(NetworkFailure(message: 'offline')),
      );
      expect(preferences.getZoneIds(), isEmpty);
    });

    test('concurrent calls share one resolution', () async {
      await setUpWith(<String, Object>{});
      remote
        ..addressZones = <int>[4]
        ..gate = Completer<void>();

      final Future<Either<Failure, List<int>>> first = repository
          .ensureZoneIds();
      final Future<Either<Failure, List<int>>> second = repository
          .ensureZoneIds();
      remote.gate!.complete();

      expect(zoneOf(await first), <int>[4]);
      expect(zoneOf(await second), <int>[4]);
      expect(remote.addressCalls, 1);
    });
  });

  group('selectZoneIds', () {
    test('stores the new zone', () async {
      await setUpWith(<String, Object>{
        'zoneIds': <String>['1'],
      });

      await repository.selectZoneIds(<int>[5]);

      expect(repository.currentZoneIds, <int>[5]);
    });

    test('ignores an empty list, keeping the current zone', () async {
      await setUpWith(<String, Object>{
        'zoneIds': <String>['1'],
      });

      await repository.selectZoneIds(<int>[]);

      expect(repository.currentZoneIds, <int>[1]);
    });
  });

  group('zoneChanges', () {
    test('announces a zone that replaces a different one', () async {
      await setUpWith(<String, Object>{
        'zoneIds': <String>['7'],
      });
      remote.addressZones = <int>[8];
      final List<List<int>> changes = <List<int>>[];
      repository.zoneChanges.listen(changes.add);

      await repository.ensureZoneIds();
      await repository.selectZoneIds(<int>[9]);
      await pumpEventQueue();

      expect(changes, <List<int>>[
        <int>[8],
        <int>[9],
      ]);
    });

    test('is quiet for the first zone and for the same zone again', () async {
      await setUpWith(<String, Object>{});
      remote.addressZones = <int>[2];
      final List<List<int>> changes = <List<int>>[];
      repository.zoneChanges.listen(changes.add);

      await repository.ensureZoneIds();
      await repository.selectZoneIds(<int>[2]);
      await pumpEventQueue();

      expect(changes, isEmpty);
    });
  });

  test('a zone that cannot be stored is a CacheFailure', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    remote = _FakeZoneRemote()..addressZones = <int>[2];
    repository = ZoneRepositoryImpl(
      remote: remote,
      location: _FakeLocation(),
      preferences: _FailingPreferences(
        instance: await SharedPreferences.getInstance(),
      ),
    );

    expect(
      await repository.ensureZoneIds(),
      const Left<Failure, List<int>>(CacheFailure()),
    );
  });

  group('ZoneRemoteDataSourceImpl', () {
    test('address zones come in order, without duplicates', () async {
      final FakeDioConsumer consumer = FakeDioConsumer(
        response: <String, dynamic>{
          'addresses': <dynamic>[
            <String, dynamic>{'zone_id': 8},
            <String, dynamic>{'zone_id': '7'},
            <String, dynamic>{'zone_id': 8},
            <String, dynamic>{'zone_id': null},
          ],
        },
      );

      expect(
        await ZoneRemoteDataSourceImpl(consumer: consumer).addressZoneIds(),
        <int>[8, 7],
      );
      expect(consumer.lastPath, ApiEndpoints.addressList);
    });

    test('the zone at a point is read from its JSON-encoded string', () async {
      final FakeDioConsumer consumer = FakeDioConsumer(
        response: <String, dynamic>{
          'zone_id': '[8]',
          'zone_data': <dynamic>[],
        },
      );

      expect(
        await ZoneRemoteDataSourceImpl(consumer: consumer).zoneIdsAt(_cairo),
        <int>[8],
      );
      expect(consumer.lastPath, ApiEndpoints.zoneAt);
      expect(consumer.lastQuery, <String, dynamic>{
        'lat': 30.0463,
        'lng': 31.3715,
      });
    });

    test('a zone lookup without an id throws ServerException', () async {
      final FakeDioConsumer consumer = FakeDioConsumer(
        response: <String, dynamic>{'zone_id': '[]'},
      );

      expect(
        () => ZoneRemoteDataSourceImpl(consumer: consumer).zoneIdsAt(_cairo),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
