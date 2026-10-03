import 'dart:math' as math;

import 'package:equatable/equatable.dart';

/// A WGS84 coordinate — an address pin, a parcel drop-off, a GPS fix.
class GeoPoint extends Equatable {
  final double latitude;
  final double longitude;

  const GeoPoint({required this.latitude, required this.longitude});

  static const double _earthRadiusKm = 6371.0088;

  /// Great-circle (straight-line) distance to [other], in km — the
  /// haversine formula. Roads are always at least this long.
  double distanceKmTo(GeoPoint other) {
    double rad(double degrees) => degrees * math.pi / 180;
    final double dLat = rad(other.latitude - latitude);
    final double dLng = rad(other.longitude - longitude);
    final double a =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(rad(latitude)) *
            math.cos(rad(other.latitude)) *
            math.pow(math.sin(dLng / 2), 2);
    return 2 * _earthRadiusKm * math.asin(math.min(1, math.sqrt(a)));
  }

  @override
  List<Object?> get props => [latitude, longitude];
}
