import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/customer_profile.dart';

/// Refusal codes for `customer/remove-account`, as [ForbiddenFailure.code].
abstract final class AccountRefusalCode {
  /// The customer has an order in progress (HTTP 203).
  static const String ongoingOrder = 'on-going';
}

abstract class AccountRepository {
  /// Also the session check: an expired token answers 401, which the network
  /// layer turns into a global sign-out.
  Future<Either<Failure, CustomerProfile>> getProfile();

  /// A duplicate phone or email answers 403 — a [ForbiddenFailure] whose
  /// `code` names the field and whose message is already localized.
  Future<Either<Failure, Unit>> updateProfile(ProfileUpdate update);

  /// Permanently removes the account and revokes the session token
  /// server-side. Refused with a [ForbiddenFailure] coded
  /// [AccountRefusalCode.ongoingOrder] while an order is in progress.
  Future<Either<Failure, Unit>> deleteAccount();
}
