import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../domain/entities/c2c_parcel_quote.dart';
import '../models/c2c_parcel_quote_model.dart';

abstract class C2cParcelsRemoteDataSource {
  Future<C2cParcelQuoteModel> getQuote(C2cQuoteRequest request);
}

class C2cParcelsRemoteDataSourceImpl implements C2cParcelsRemoteDataSource {
  final DioConsumer consumer;

  const C2cParcelsRemoteDataSourceImpl({required this.consumer});

  /// Body as in the API guide's example: coordinates and weight as numbers.
  /// A blank title is left out rather than sent empty.
  @override
  Future<C2cParcelQuoteModel> getQuote(C2cQuoteRequest request) async =>
      C2cParcelQuoteModel.fromJson(
        await consumer.post(
          ApiEndpoints.c2cParcelQuote,
          body: <String, dynamic>{
            'sender_latitude': request.sender.latitude,
            'sender_longitude': request.sender.longitude,
            'recipient_latitude': request.recipient.latitude,
            'recipient_longitude': request.recipient.longitude,
            'category': request.size.name,
            'weight_kg': request.weightKg,
            'is_fragile': request.isFragile,
            if (request.title case final String title when title.isNotEmpty)
              'title': title,
          },
        ),
      );
}
