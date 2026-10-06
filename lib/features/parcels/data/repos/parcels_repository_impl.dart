import 'package:dartz/dartz.dart';

import '../../../../core/api/safe_api_call.dart';
import '../../../../core/delivery_otp/delivery_otp.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/parcel.dart';
import '../../domain/repos/parcels_repository.dart';
import '../datasources/parcels_remote_data_source.dart';

class ParcelsRepositoryImpl implements ParcelsRepository {
  final ParcelsRemoteDataSource remote;

  const ParcelsRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, List<Parcel>>> getParcels() =>
      safeApiCall(remote.getParcels);

  @override
  Future<Either<Failure, Unit>> sendDropoff(
    int parcelId,
    ParcelDropoff dropoff,
  ) => safeApiCall(() async {
    await remote.sendDropoff(parcelId, dropoff);
    return unit;
  });

  @override
  Future<Either<Failure, DeliveryOtp>> requestDeliveryOtp(int parcelId) =>
      safeApiCall(() => remote.requestDeliveryOtp(parcelId));
}
