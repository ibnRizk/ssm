import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/c2c_parcel.dart';
import '../entities/c2c_parcel_draft.dart';
import '../entities/c2c_parcel_quote.dart';
import '../entities/c2c_parcel_status.dart';

/// Door-to-door parcels the customer sends or receives — separate from the
/// warehouse parcels of `ParcelsRepository`.
///
/// Refusals carry their `errors[0].code` (see [C2cParcelErrorCode]): 409s
/// as [ConflictFailure], 422s as [ServerFailure]. Commands that take an
/// `idempotencyKey` replay their first successful answer when sent again
/// with the same key and body, so a retry after a lost answer is safe.
abstract class C2cParcelsRepository {
  /// The server applies the best eligible parcel plan by itself. A parcel
  /// beyond the allowed distance or weight answers 422 with its message.
  Future<Either<Failure, C2cParcelQuote>> getQuote(C2cQuoteRequest request);

  /// Creates the parcel and starts looking for a driver. An outdated
  /// `quote_token` answers 409 [C2cParcelErrorCode.priceChanged] or
  /// [C2cParcelErrorCode.quoteExpired].
  Future<Either<Failure, C2cParcelDetails>> createParcel(
    C2cParcelDraft draft, {
    required String idempotencyKey,
  });

  /// [offset] is the 1-based page number; [status] a canonical status, or
  /// `active` / `completed`.
  Future<Either<Failure, C2cParcelPage>> getParcels(
    C2cParcelBox box, {
    int limit,
    int offset,
    String? status,
  });

  /// Someone else's parcel answers 404 like a missing one.
  Future<Either<Failure, C2cParcelDetails>> getParcelDetails(int parcelId);

  Future<Either<Failure, C2cParcelTracking>> getTracking(int parcelId);

  /// Sender only, before pickup. [expectedVersion] is the `status_version`
  /// the customer saw; a newer one answers 409
  /// [C2cParcelErrorCode.staleVersion].
  Future<Either<Failure, Unit>> cancelParcel(
    int parcelId, {
    required C2cCancelReason reason,
    required int expectedVersion,
    required String idempotencyKey,
    String? note,
  });

  /// Sender only, after `assignment_failed`.
  Future<Either<Failure, Unit>> retryDispatch(
    int parcelId, {
    required int expectedVersion,
    required String idempotencyKey,
  });

  /// A delivery code (recipient or sender, while out for delivery) or the
  /// sender's return code (while returning). A new code replaces the old.
  /// Throttled to 5 per minute.
  Future<Either<Failure, C2cParcelOtp>> requestOtp(int parcelId);

  Future<Either<Failure, Unit>> openSupportCase(
    int parcelId, {
    required C2cSupportReason reason,
    required String description,
    required String idempotencyKey,
  });

  /// Lets the customer photograph or pick parcel photos — at most [limit]
  /// from the gallery, one from the camera. An empty list when they
  /// cancelled; a [MediaPickerFailure] when access was refused.
  Future<Either<Failure, List<C2cParcelPhoto>>> pickPhotos(
    C2cPhotoSource source, {
    required int limit,
  });
}
