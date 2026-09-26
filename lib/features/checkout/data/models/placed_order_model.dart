import '../../../../core/api/api_error_mapper.dart';
import '../../../../core/api/json_readers.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/order_request.dart';

/// `{ "message", "order_id", "total_ammount", "status", ... }` — the
/// misspelled `total_ammount` is the real field name.
class PlacedOrderModel extends PlacedOrder {
  const PlacedOrderModel({required super.id, super.totalAmount});

  /// `order/place` also refuses with HTTP 203 — a success status whose body
  /// is `{"errors":[{"code","message"}]}`. That's thrown as the same
  /// [ForbiddenException] a 403 refusal becomes. Throws [ServerException]
  /// for any other body without an order id.
  factory PlacedOrderModel.fromJson(dynamic json) {
    if (json is Map && json['errors'] is List) {
      throw ForbiddenException(
        message: apiErrorMessage(json),
        code: apiErrorCode(json),
      );
    }
    final int? id = json is Map ? jsonInt(json['order_id']) : null;
    if (json is! Map || id == null) throw const ServerException();
    return PlacedOrderModel(
      id: id,
      totalAmount: jsonDouble(json['total_ammount'] ?? json['total_amount']),
    );
  }
}
