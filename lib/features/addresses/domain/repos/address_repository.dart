import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/address.dart';

abstract class AddressRepository {
  /// Only the signed-in customer's addresses.
  Future<Either<Failure, List<Address>>> getAddresses();

  /// A location outside every delivery zone answers 403 — a
  /// [ForbiddenFailure] with code [outOfCoverageCode].
  Future<Either<Failure, Unit>> addAddress(NewAddress address);

  /// A missing or foreign id answers 404.
  Future<Either<Failure, Unit>> deleteAddress(int id);
}

/// `errors[0].code` for an address outside every delivery zone.
const String outOfCoverageCode = 'coordinates';
