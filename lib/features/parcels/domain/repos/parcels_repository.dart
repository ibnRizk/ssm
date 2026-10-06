import 'package:dartz/dartz.dart';

import '../../../../core/delivery_otp/delivery_otp.dart';
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

  /// The code the customer reads to the courier. A [ConflictFailure] means
  /// the parcel isn't out for delivery on the server (yet). A new request
  /// invalidates the previous code.
  Future<Either<Failure, DeliveryOtp>> requestDeliveryOtp(int parcelId);
}
