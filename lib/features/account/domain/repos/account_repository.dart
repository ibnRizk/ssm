import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/customer_profile.dart';

abstract class AccountRepository {
  /// Also the session check: an expired token answers 401, which the network
  /// layer turns into a global sign-out.
  Future<Either<Failure, CustomerProfile>> getProfile();

  /// A duplicate phone or email answers 403 — a [ForbiddenFailure] whose
  /// `code` names the field and whose message is already localized.
  Future<Either<Failure, Unit>> updateProfile(ProfileUpdate update);
}
