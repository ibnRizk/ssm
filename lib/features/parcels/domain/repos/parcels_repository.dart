import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/parcel.dart';

abstract class ParcelsRepository {
  /// The first page, newest first.
  Future<Either<Failure, List<Parcel>>> getParcels();

  /// Invalid coordinates or an already-delivered parcel answer 422; a
  /// parcel that isn't the customer's answers 404. Both carry the server's
  /// message.
  Future<Either<Failure, Unit>> sendDropoff(
    int parcelId,
    ParcelDropoff dropoff,
  );
}
