import 'package:equatable/equatable.dart';

/// A WGS84 coordinate — an address pin, a parcel drop-off, a GPS fix.
class GeoPoint extends Equatable {
  final double latitude;
  final double longitude;

  const GeoPoint({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}
