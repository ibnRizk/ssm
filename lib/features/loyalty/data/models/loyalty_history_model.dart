import '../../../../core/api/json_readers.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/loyalty_history.dart';

/// `GET /customer/loyalty/history` → `{ "data": [...], "pagination": {
/// "total", … } }`. Entry fields aren't read — see [LoyaltyHistory].
class LoyaltyHistoryModel extends LoyaltyHistory {
  const LoyaltyHistoryModel({required super.total, required super.recentCount});

  /// Throws [ServerException] when `data` isn't a list.
  factory LoyaltyHistoryModel.fromJson(dynamic json) {
    final dynamic data = json is Map ? json['data'] : null;
    if (data is! List) throw const ServerException();
    final dynamic pagination = (json as Map)['pagination'];
    final int? total = pagination is Map ? jsonInt(pagination['total']) : null;
    return LoyaltyHistoryModel(
      total: total ?? data.length,
      recentCount: data.length,
    );
  }
}
