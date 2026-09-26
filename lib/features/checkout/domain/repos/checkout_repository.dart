import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/order_request.dart';

/// Refusal codes the backend sends for `order/place`, as
/// [ForbiddenFailure.code] (HTTP 403, or a 203 whose body is an error).
abstract final class OrderRefusalCode {
  /// The address is outside the store's delivery zone.
  static const String coordinates = 'coordinates';

  /// The total is above the zone's cash-on-delivery maximum.
  static const String orderAmount = 'order_amount';
}

abstract class CheckoutRepository {
  /// Places the cart as a cash-on-delivery delivery order. Business-rule
  /// refusals come back as [ForbiddenFailure] — see [OrderRefusalCode].
  Future<Either<Failure, PlacedOrder>> placeOrder(OrderRequest request);
}
