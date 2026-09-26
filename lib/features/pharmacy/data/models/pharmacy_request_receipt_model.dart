import '../../../../core/api/json_readers.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/pharmacy_request.dart';

/// The 201 body: `{ "pharmacy_request": { "id", ... }, "warning": "..." }`.
class PharmacyRequestReceiptModel extends PharmacyRequestReceipt {
  const PharmacyRequestReceiptModel({required super.id, super.warning});

  /// Throws [ServerException] without the created request's id.
  factory PharmacyRequestReceiptModel.fromJson(dynamic json) {
    final dynamic request = json is Map ? json['pharmacy_request'] : null;
    final int? id = request is Map ? jsonInt(request['id']) : null;
    if (id == null) throw const ServerException();
    return PharmacyRequestReceiptModel(
      id: id,
      warning: jsonString((json as Map)['warning']),
    );
  }
}
