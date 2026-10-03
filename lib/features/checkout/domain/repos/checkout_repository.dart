import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/order_quote.dart';
import '../entities/order_request.dart';

/// Refusal codes the backend sends for `order/place`, as
/// [ForbiddenFailure.code] (HTTP 403, or a 203 whose body is an error).
abstract final class OrderRefusalCode {
  /// The address is outside the store's delivery zone.
  static const String coordinates = 'coordinates';

  /// The total is above the zone's cash-on-delivery maximum.
  static const String orderAmount = 'order_amount';
}

/// 409 codes of `order/place`'s idempotency, as [ConflictFailure.code].
abstract final class IdempotencyCode {
  /// The first request with this key is still being processed — its
  /// outcome isn't known yet; retry later with the same key.
  static const String inProgress = 'order_in_progress';

  /// The key was already used with a different body.
  static const String conflict = 'idempotency_conflict';
}

abstract class CheckoutRepository {
  /// The authoritative price breakdown of the cart — what the checkout
  /// shows. Unknown store or empty cart: [NotFoundFailure] or a 422
  /// [ServerFailure] carrying the server's message.
  Future<Either<Failure, OrderQuote>> getQuote(QuoteRequest request);

  /// Places the cart as a cash-on-delivery delivery order. Business-rule
  /// refusals come back as [ForbiddenFailure] — see [OrderRefusalCode].
  ///
  /// [idempotencyKey] identifies this checkout attempt: sent again with the
  /// same request after a lost answer, the server replays the first result
  /// instead of creating a second order. See [IdempotencyCode].
  Future<Either<Failure, PlacedOrder>> placeOrder(
    OrderRequest request, {
    required String idempotencyKey,
  });
}
