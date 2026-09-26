import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../domain/entities/parcel.dart';
import '../models/parcel_model.dart';

abstract class ParcelsRemoteDataSource {
  Future<List<ParcelModel>> getParcels();

  Future<void> sendDropoff(int parcelId, ParcelDropoff dropoff);
}

class ParcelsRemoteDataSourceImpl implements ParcelsRemoteDataSource {
  final DioConsumer consumer;

  const ParcelsRemoteDataSourceImpl({required this.consumer});

  @override
  Future<List<ParcelModel>> getParcels() async =>
      ParcelModel.listFromJson(await consumer.get(ApiEndpoints.parcels));

  /// Coordinates go as numbers, as in the API guide's example. Empty notes
  /// are left out rather than sent blank.
  @override
  Future<void> sendDropoff(int parcelId, ParcelDropoff dropoff) =>
      consumer.post(
        ApiEndpoints.parcelLocation(parcelId),
        body: <String, dynamic>{
          'latitude': dropoff.location.latitude,
          'longitude': dropoff.location.longitude,
          'delivery_address': dropoff.deliveryAddress,
          if (dropoff.notes case final String notes when notes.isNotEmpty)
            'notes': notes,
        },
      );
}
