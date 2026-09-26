import 'package:dartz/dartz.dart';

import '../api/safe_api_call.dart';
import '../error/failures.dart';
import 'geo_point.dart';
import 'location_repository.dart';
import 'device_location_data_source.dart';

class LocationRepositoryImpl implements LocationRepository {
  final DeviceLocationDataSource device;

  const LocationRepositoryImpl({required this.device});

  /// [safeApiCall] is the generic boundary catch — it folds the
  /// [LocationException]s thrown here the same way as network ones.
  @override
  Future<Either<Failure, GeoPoint>> getCurrentLocation() =>
      safeApiCall(device.getCurrentLocation);
}
