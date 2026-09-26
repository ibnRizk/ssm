import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/cart.dart';

/// The signed-in customer's server-side cart. Every change answers with the
/// cart as it is afterwards. An unknown or foreign cart line answers 404 —
/// a [NotFoundFailure].
abstract class CartRepository {
  Future<Either<Failure, Cart>> getCart();

  /// [unitPrice] is what the customer saw; the server recomputes it when
  /// the order is placed.
  Future<Either<Failure, Cart>> addItem({
    required int itemId,
    required double unitPrice,
    int quantity = 1,
  });

  /// [quantity] must be at least 1 — use [removeLine] to drop a line.
  Future<Either<Failure, Cart>> updateQuantity({
    required int cartLineId,
    required int quantity,
  });

  Future<Either<Failure, Cart>> removeLine(int cartLineId);
}
