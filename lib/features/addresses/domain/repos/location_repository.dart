import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/address.dart';

abstract class LocationRepository {
  /// Asks for permission if needed. Fails with a [LocationFailure] when
  /// location services are off or access is denied.
  Future<Either<Failure, GeoPoint>> getCurrentLocation();
}
