import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../error/exceptions.dart';
import '../error/failures.dart';
import 'geo_point.dart';

/// The device GPS, behind an interface so repositories stay unit-testable.
abstract class DeviceLocationDataSource {
  /// Throws only [LocationException] — never a geolocator type — when
  /// services are off, access is denied, or no fix arrives.
  Future<GeoPoint> getCurrentLocation();
}

class DeviceLocationDataSourceImpl implements DeviceLocationDataSource {
  /// Geolocator's platform interface (what its static API delegates to),
  /// injected so tests can make it fail in each way it can.
  final GeolocatorPlatform _platform;

  DeviceLocationDataSourceImpl({GeolocatorPlatform? platform})
    : _platform = platform ?? GeolocatorPlatform.instance;

  static const Duration _timeLimit = Duration(seconds: 15);

  /// The one boundary where geolocator errors become [LocationException]s,
  /// so the UI can tell "turn on GPS" from "allow access" from "try again".
  @override
  Future<GeoPoint> getCurrentLocation() async {
    try {
      return await _locate();
    } on LocationException {
      rethrow;
    } on LocationServiceDisabledException {
      throw const LocationException(
        reason: LocationFailureReason.serviceDisabled,
      );
    } on PermissionDeniedException {
      // Also covers `unableToDetermine` turning out to mean "denied".
      throw const LocationException(
        reason: LocationFailureReason.permissionDenied,
      );
    } on TimeoutException {
      throw const LocationException(reason: LocationFailureReason.unavailable);
    } catch (_) {
      // PositionUpdateException (no usable fix), a permission prompt
      // already open, platform channel errors — all "try again" for the
      // customer.
      throw const LocationException(reason: LocationFailureReason.unavailable);
    }
  }

  Future<GeoPoint> _locate() async {
    if (!await _platform.isLocationServiceEnabled()) {
      throw const LocationException(
        reason: LocationFailureReason.serviceDisabled,
      );
    }

    LocationPermission permission = await _platform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _platform.requestPermission();
    }
    switch (permission) {
      case LocationPermission.denied:
        throw const LocationException(
          reason: LocationFailureReason.permissionDenied,
        );
      case LocationPermission.deniedForever:
        throw const LocationException(
          reason: LocationFailureReason.deniedForever,
        );
      // `unableToDetermine` (web): try anyway — a refusal then arrives as
      // PermissionDeniedException and is mapped above.
      case LocationPermission.whileInUse ||
          LocationPermission.always ||
          LocationPermission.unableToDetermine:
        break;
    }

    final Position position = await _platform.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: _timeLimit,
      ),
    );
    return GeoPoint(latitude: position.latitude, longitude: position.longitude);
  }
}
