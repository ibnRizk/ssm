import 'package:dartz/dartz.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/features/c2c_parcels/domain/entities/c2c_parcel.dart';
import 'package:ssm/features/c2c_parcels/domain/entities/c2c_parcel_draft.dart';
import 'package:ssm/features/c2c_parcels/domain/entities/c2c_parcel_quote.dart';
import 'package:ssm/features/c2c_parcels/domain/entities/c2c_parcel_status.dart';
import 'package:ssm/features/c2c_parcels/domain/repos/c2c_parcels_repository.dart';

/// Every call is recorded and answered by a handler the test sets (a
/// `Completer`'s future when it wants to control timing). An unset handler
/// fails the test loudly.
class FakeC2cParcelsRepository implements C2cParcelsRepository {
  Future<Either<Failure, C2cParcelQuote>> Function(C2cQuoteRequest)? onQuote;
  Future<Either<Failure, C2cParcelDetails>> Function(C2cParcelDraft, String)?
  onCreate;
  Future<Either<Failure, C2cParcelPage>> Function(C2cParcelBox, int, int)?
  onPage;
  Future<Either<Failure, C2cParcelDetails>> Function()? onDetails;
  Future<Either<Failure, C2cParcelTracking>> Function()? onTracking;
  Future<Either<Failure, Unit>> Function()? onCommand;
  Future<Either<Failure, C2cParcelOtp>> Function()? onOtp;
  Future<Either<Failure, List<C2cParcelPhoto>>> Function(C2cPhotoSource, int)?
  onPick;

  final List<C2cQuoteRequest> quotes = <C2cQuoteRequest>[];
  final List<(C2cParcelDraft, String)> creates = <(C2cParcelDraft, String)>[];
  final List<(C2cParcelBox, int, int)> pages = <(C2cParcelBox, int, int)>[];
  int detailsCalls = 0;
  int trackingCalls = 0;
  int otpCalls = 0;

  /// `(command, expectedVersion, idempotencyKey)` per command sent.
  final List<(String, int?, String)> commands = <(String, int?, String)>[];

  Never _unset(String name) => throw StateError('No handler for $name');

  @override
  Future<Either<Failure, C2cParcelQuote>> getQuote(C2cQuoteRequest request) {
    quotes.add(request);
    return (onQuote ?? _unset('getQuote'))(request);
  }

  @override
  Future<Either<Failure, C2cParcelDetails>> createParcel(
    C2cParcelDraft draft, {
    required String idempotencyKey,
  }) {
    creates.add((draft, idempotencyKey));
    return (onCreate ?? _unset('createParcel'))(draft, idempotencyKey);
  }

  @override
  Future<Either<Failure, C2cParcelPage>> getParcels(
    C2cParcelBox box, {
    int limit = 15,
    int offset = 1,
    String? status,
  }) {
    pages.add((box, limit, offset));
    return (onPage ?? _unset('getParcels'))(box, limit, offset);
  }

  @override
  Future<Either<Failure, C2cParcelDetails>> getParcelDetails(int parcelId) {
    detailsCalls++;
    return (onDetails ?? _unset('getParcelDetails'))();
  }

  @override
  Future<Either<Failure, C2cParcelTracking>> getTracking(int parcelId) {
    trackingCalls++;
    return (onTracking ?? _unset('getTracking'))();
  }

  @override
  Future<Either<Failure, Unit>> cancelParcel(
    int parcelId, {
    required C2cCancelReason reason,
    required int expectedVersion,
    required String idempotencyKey,
    String? note,
  }) {
    commands.add(('cancel', expectedVersion, idempotencyKey));
    return (onCommand ?? _unset('cancelParcel'))();
  }

  @override
  Future<Either<Failure, Unit>> retryDispatch(
    int parcelId, {
    required int expectedVersion,
    required String idempotencyKey,
  }) {
    commands.add(('retry', expectedVersion, idempotencyKey));
    return (onCommand ?? _unset('retryDispatch'))();
  }

  @override
  Future<Either<Failure, C2cParcelOtp>> requestOtp(int parcelId) {
    otpCalls++;
    return (onOtp ?? _unset('requestOtp'))();
  }

  @override
  Future<Either<Failure, Unit>> openSupportCase(
    int parcelId, {
    required C2cSupportReason reason,
    required String description,
    required String idempotencyKey,
  }) {
    commands.add(('support', null, idempotencyKey));
    return (onCommand ?? _unset('openSupportCase'))();
  }

  @override
  Future<Either<Failure, List<C2cParcelPhoto>>> pickPhotos(
    C2cPhotoSource source, {
    required int limit,
  }) => (onPick ?? _unset('pickPhotos'))(source, limit);
}
