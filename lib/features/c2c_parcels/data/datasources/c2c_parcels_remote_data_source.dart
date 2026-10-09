import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../domain/entities/c2c_parcel.dart';
import '../../domain/entities/c2c_parcel_draft.dart';
import '../../domain/entities/c2c_parcel_quote.dart';
import '../../domain/entities/c2c_parcel_status.dart';
import '../models/c2c_parcel_models.dart';
import '../models/c2c_parcel_quote_model.dart';
import '../models/requests/c2c_parcel_form.dart';

abstract class C2cParcelsRemoteDataSource {
  Future<C2cParcelQuoteModel> getQuote(C2cQuoteRequest request);

  Future<C2cParcelDetails> createParcel(
    C2cParcelDraft draft, {
    required String idempotencyKey,
  });

  Future<C2cParcelPage> getParcels(
    C2cParcelBox box, {
    required int limit,
    required int offset,
    String? status,
  });

  Future<C2cParcelDetails> getParcelDetails(int parcelId);

  Future<C2cParcelTracking> getTracking(int parcelId);

  Future<void> cancelParcel(
    int parcelId, {
    required C2cCancelReason reason,
    required int expectedVersion,
    required String idempotencyKey,
    String? note,
  });

  Future<void> retryDispatch(
    int parcelId, {
    required int expectedVersion,
    required String idempotencyKey,
  });

  Future<C2cParcelOtp> requestOtp(int parcelId);

  Future<void> openSupportCase(
    int parcelId, {
    required C2cSupportReason reason,
    required String description,
    required String idempotencyKey,
  });
}

class C2cParcelsRemoteDataSourceImpl implements C2cParcelsRemoteDataSource {
  final DioConsumer consumer;

  const C2cParcelsRemoteDataSourceImpl({required this.consumer});

  /// Required on create; recommended on the customer's other commands.
  static const String idempotencyHeader = 'Idempotency-Key';

  static Map<String, String> _idempotent(String key) => <String, String>{
    idempotencyHeader: key,
  };

  /// Up to five 5 MB photos on a slow mobile link; past this the upload
  /// fails as a timeout (outcome unknown, so the retry reuses the key).
  static const Duration uploadTimeout = Duration(seconds: 90);

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
            'category': request.category.name,
            'weight_kg': request.weightKg,
            'is_fragile': request.isFragile,
            if (request.title case final String title when title.isNotEmpty)
              'title': title,
          },
        ),
      );

  @override
  Future<C2cParcelDetails> createParcel(
    C2cParcelDraft draft, {
    required String idempotencyKey,
  }) async => C2cParcelModels.detailsFromJson(
    await consumer.post(
      ApiEndpoints.c2cParcels,
      formData: await C2cParcelForm(draft).toFormData(),
      headers: _idempotent(idempotencyKey),
      sendTimeout: uploadTimeout,
    ),
  );

  @override
  Future<C2cParcelPage> getParcels(
    C2cParcelBox box, {
    required int limit,
    required int offset,
    String? status,
  }) async => C2cParcelModels.pageFromJson(
    await consumer.get(
      switch (box) {
        C2cParcelBox.sent => ApiEndpoints.c2cParcels,
        C2cParcelBox.received => ApiEndpoints.c2cParcelsReceived,
      },
      queryParameters: <String, dynamic>{
        'limit': limit,
        'offset': offset,
        'status': ?status,
      },
    ),
    box: box,
    limit: limit,
    offset: offset,
  );

  @override
  Future<C2cParcelDetails> getParcelDetails(int parcelId) async =>
      C2cParcelModels.detailsFromJson(
        await consumer.get(ApiEndpoints.c2cParcel(parcelId)),
      );

  @override
  Future<C2cParcelTracking> getTracking(int parcelId) async =>
      C2cParcelModels.trackingFromJson(
        await consumer.get(ApiEndpoints.c2cParcelTracking(parcelId)),
      );

  @override
  Future<void> cancelParcel(
    int parcelId, {
    required C2cCancelReason reason,
    required int expectedVersion,
    required String idempotencyKey,
    String? note,
  }) => consumer.post(
    ApiEndpoints.c2cParcelCancel(parcelId),
    body: <String, dynamic>{
      'reason_code': reason.wire,
      if (note?.trim() case final String text when text.isNotEmpty)
        'note': text,
      'expected_version': expectedVersion,
    },
    headers: _idempotent(idempotencyKey),
  );

  @override
  Future<void> retryDispatch(
    int parcelId, {
    required int expectedVersion,
    required String idempotencyKey,
  }) => consumer.post(
    ApiEndpoints.c2cParcelRetryDispatch(parcelId),
    body: <String, dynamic>{'expected_version': expectedVersion},
    headers: _idempotent(idempotencyKey),
  );

  @override
  Future<C2cParcelOtp> requestOtp(int parcelId) async =>
      C2cParcelModels.otpFromJson(
        await consumer.post(
          ApiEndpoints.c2cParcelOtpRequest(parcelId),
          body: const <String, dynamic>{},
        ),
      );

  @override
  Future<void> openSupportCase(
    int parcelId, {
    required C2cSupportReason reason,
    required String description,
    required String idempotencyKey,
  }) => consumer.post(
    ApiEndpoints.c2cParcelSupport(parcelId),
    body: <String, dynamic>{
      'reason_code': reason.wire,
      'description': description.trim(),
    },
    headers: _idempotent(idempotencyKey),
  );
}
