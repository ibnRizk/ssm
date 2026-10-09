import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/c2c_parcel_quote.dart';

/// Door-to-door parcels the customer sends — separate from the warehouse
/// parcels of `ParcelsRepository`.
abstract class C2cParcelsRepository {
  /// The server applies the best eligible parcel plan by itself. A parcel
  /// beyond the allowed distance or weight answers 422 with its message.
  Future<Either<Failure, C2cParcelQuote>> getQuote(C2cQuoteRequest request);
}
