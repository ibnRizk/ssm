import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/address.dart';

/// The device GPS, behind an interface so repositories stay unit-testable
/// (geolocator's API is static).
abstract class DeviceLocationDataSource {
  /// Throws [LocationException] when services are off, access is denied, or
  /// no fix arrives in time.
  Future<GeoPoint> getCurrentLocation();
}

class DeviceLocationDataSourceImpl implements DeviceLocationDataSource {
  const DeviceLocationDataSourceImpl();

  static const Duration _timeLimit = Duration(seconds: 15);

  @override
  Future<GeoPoint> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(
        reason: LocationFailureReason.serviceDisabled,
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
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
      case LocationPermission.whileInUse ||
          LocationPermission.always ||
          LocationPermission.unableToDetermine:
        break;
    }

    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: _timeLimit,
        ),
      );
      return GeoPoint(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } on TimeoutException {
      throw const LocationException(reason: LocationFailureReason.unavailable);
    } on LocationServiceDisabledException {
      throw const LocationException(
        reason: LocationFailureReason.serviceDisabled,
      );
    }
  }
}
