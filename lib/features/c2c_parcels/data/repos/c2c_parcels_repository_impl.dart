import 'package:dartz/dartz.dart';

import '../../../../core/api/safe_api_call.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/c2c_parcel.dart';
import '../../domain/entities/c2c_parcel_draft.dart';
import '../../domain/entities/c2c_parcel_quote.dart';
import '../../domain/entities/c2c_parcel_status.dart';
import '../../domain/repos/c2c_parcels_repository.dart';
import '../datasources/c2c_parcels_remote_data_source.dart';
import '../datasources/c2c_photo_picker_data_source.dart';

class C2cParcelsRepositoryImpl implements C2cParcelsRepository {
  final C2cParcelsRemoteDataSource remote;
  final C2cPhotoPickerDataSource photoPicker;

  const C2cParcelsRepositoryImpl({
    required this.remote,
    required this.photoPicker,
  });

  /// A page size the lists use unless told otherwise; the API caps it at 50.
  static const int defaultPageSize = 15;

  @override
  Future<Either<Failure, C2cParcelQuote>> getQuote(C2cQuoteRequest request) =>
      safeApiCall(() => remote.getQuote(request));

  @override
  Future<Either<Failure, C2cParcelDetails>> createParcel(
    C2cParcelDraft draft, {
    required String idempotencyKey,
  }) => safeApiCall(
    () => remote.createParcel(draft, idempotencyKey: idempotencyKey),
  );

  @override
  Future<Either<Failure, C2cParcelPage>> getParcels(
    C2cParcelBox box, {
    int limit = defaultPageSize,
    int offset = 1,
    String? status,
  }) => safeApiCall(
    () => remote.getParcels(box, limit: limit, offset: offset, status: status),
  );

  @override
  Future<Either<Failure, C2cParcelDetails>> getParcelDetails(int parcelId) =>
      safeApiCall(() => remote.getParcelDetails(parcelId));

  @override
  Future<Either<Failure, C2cParcelTracking>> getTracking(int parcelId) =>
      safeApiCall(() => remote.getTracking(parcelId));

  @override
  Future<Either<Failure, Unit>> cancelParcel(
    int parcelId, {
    required C2cCancelReason reason,
    required int expectedVersion,
    required String idempotencyKey,
    String? note,
  }) => safeApiCall(() async {
    await remote.cancelParcel(
      parcelId,
      reason: reason,
      expectedVersion: expectedVersion,
      idempotencyKey: idempotencyKey,
      note: note,
    );
    return unit;
  });

  @override
  Future<Either<Failure, Unit>> retryDispatch(
    int parcelId, {
    required int expectedVersion,
    required String idempotencyKey,
  }) => safeApiCall(() async {
    await remote.retryDispatch(
      parcelId,
      expectedVersion: expectedVersion,
      idempotencyKey: idempotencyKey,
    );
    return unit;
  });

  @override
  Future<Either<Failure, C2cParcelOtp>> requestOtp(int parcelId) =>
      safeApiCall(() => remote.requestOtp(parcelId));

  @override
  Future<Either<Failure, Unit>> openSupportCase(
    int parcelId, {
    required C2cSupportReason reason,
    required String description,
    required String idempotencyKey,
  }) => safeApiCall(() async {
    await remote.openSupportCase(
      parcelId,
      reason: reason,
      description: description,
      idempotencyKey: idempotencyKey,
    );
    return unit;
  });

  @override
  Future<Either<Failure, List<C2cParcelPhoto>>> pickPhotos(
    C2cPhotoSource source, {
    required int limit,
  }) => safeApiCall(() => photoPicker.pick(source, limit: limit));
}
