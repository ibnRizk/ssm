import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/order_tracking.dart';

/// Error code of the 409 the delivery-OTP request answers outside
/// `out_for_delivery`, as [ConflictFailure.code].
const String otpNotAvailableCode = 'otp-not-available';

/// Another customer's order answers [NotFoundFailure] everywhere.
abstract class OrderTrackingRepository {
  Future<Either<Failure, OrderSummary>> getSummary(int orderId);

  Future<Either<Failure, List<OrderLine>>> getLines(int orderId);

  Future<Either<Failure, OrderTracking>> getTracking(int orderId);

  /// Only while the order is out for delivery; otherwise a
  /// [ConflictFailure] ([otpNotAvailableCode]). Invalidates the previous
  /// code.
  Future<Either<Failure, DeliveryOtp>> requestDeliveryOtp(int orderId);

  /// Only while the merchant hasn't accepted the order; afterwards a
  /// [ForbiddenFailure]. Repeating a successful cancel is safe.
  Future<Either<Failure, Unit>> cancelOrder(
    int orderId, {
    required String reason,
  });
}
