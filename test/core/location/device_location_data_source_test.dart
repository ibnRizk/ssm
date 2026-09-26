import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_base/core/error/exceptions.dart';
import 'package:flutter_base/core/error/failures.dart';
import 'package:flutter_base/core/location/device_location_data_source.dart';
import 'package:flutter_base/core/location/geo_point.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

/// Geolocator's platform interface, scripted per test: service state,
/// permission answers, and what reading the position does.
class _FakeGeolocator extends GeolocatorPlatform {
  bool serviceEnabled = true;
  LocationPermission permission = LocationPermission.whileInUse;
  LocationPermission afterRequest = LocationPermission.whileInUse;
  Object? positionError;
  int requests = 0;

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<LocationPermission> requestPermission() async {
    requests++;
    return afterRequest;
  }

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    if (positionError case final Object e) throw e;
    return Position(
      latitude: 24.71,
      longitude: 46.68,
      timestamp: DateTime(2026),
      accuracy: 5,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }
}

Matcher _throwsLocation(LocationFailureReason reason) => throwsA(
  isA<LocationException>().having(
    (LocationException e) => e.reason,
    'reason',
    reason,
  ),
);

void main() {
  late _FakeGeolocator platform;
  late DeviceLocationDataSourceImpl source;

  setUp(() {
    platform = _FakeGeolocator();
    source = DeviceLocationDataSourceImpl(platform: platform);
  });

  test('returns the fix as a GeoPoint', () async {
    expect(
      await source.getCurrentLocation(),
      const GeoPoint(latitude: 24.71, longitude: 46.68),
    );
  });

  test('asks for permission once when not yet granted', () async {
    platform.permission = LocationPermission.denied;

    await source.getCurrentLocation();

    expect(platform.requests, 1);
  });

  group('maps every failure to a typed LocationException', () {
    test('location services off', () {
      platform.serviceEnabled = false;

      expect(
        source.getCurrentLocation(),
        _throwsLocation(LocationFailureReason.serviceDisabled),
      );
    });

    test('permission refused at the prompt', () {
      platform
        ..permission = LocationPermission.denied
        ..afterRequest = LocationPermission.denied;

      expect(
        source.getCurrentLocation(),
        _throwsLocation(LocationFailureReason.permissionDenied),
      );
    });

    test('permission denied forever', () {
      platform.permission = LocationPermission.deniedForever;

      expect(
        source.getCurrentLocation(),
        _throwsLocation(LocationFailureReason.deniedForever),
      );
    });

    test('unableToDetermine that turns out to be a refusal', () {
      platform
        ..permission = LocationPermission.unableToDetermine
        ..positionError = const PermissionDeniedException('denied');

      expect(
        source.getCurrentLocation(),
        _throwsLocation(LocationFailureReason.permissionDenied),
      );
    });

    test('services switched off while reading the position', () {
      platform.positionError = const LocationServiceDisabledException();

      expect(
        source.getCurrentLocation(),
        _throwsLocation(LocationFailureReason.serviceDisabled),
      );
    });

    test('no fix in time', () {
      platform.positionError = TimeoutException('no fix');

      expect(
        source.getCurrentLocation(),
        _throwsLocation(LocationFailureReason.unavailable),
      );
    });

    test('a GPS error (weak signal)', () {
      platform.positionError = const PositionUpdateException('weak signal');

      expect(
        source.getCurrentLocation(),
        _throwsLocation(LocationFailureReason.unavailable),
      );
    });

    test('a permission prompt already open', () {
      platform
        ..permission = LocationPermission.whileInUse
        ..positionError = const PermissionRequestInProgressException(
          'already requesting',
        );

      expect(
        source.getCurrentLocation(),
        _throwsLocation(LocationFailureReason.unavailable),
      );
    });

    test('a platform channel error', () {
      platform.positionError = PlatformException(code: 'ERROR');

      expect(
        source.getCurrentLocation(),
        _throwsLocation(LocationFailureReason.unavailable),
      );
    });
  });
}
