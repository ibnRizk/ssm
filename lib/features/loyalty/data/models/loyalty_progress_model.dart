import '../../../../core/error/exceptions.dart';
import '../../domain/entities/loyalty_progress.dart';

/// `GET /customer/loyalty` → `{ "data": { current_progress,
/// eligible_orders_required, … } }`. Deliberately not the legacy
/// `loyalty_point` field on `/customer/info`, which the API guide says to
/// ignore.
class LoyaltyProgressModel extends LoyaltyProgress {
  const LoyaltyProgressModel({
    required super.currentProgress,
    required super.eligibleOrdersRequired,
  });

  /// Throws [ServerException] when the body lacks the progress fields.
  factory LoyaltyProgressModel.fromJson(dynamic json) {
    final dynamic data = json is Map ? json['data'] : null;
    final int? current = data is Map ? _toInt(data['current_progress']) : null;
    final int? target = data is Map
        ? _toInt(data['eligible_orders_required'])
        : null;
    if (current == null || target == null) throw const ServerException();
    return LoyaltyProgressModel(
      currentProgress: current,
      eligibleOrdersRequired: target,
    );
  }

  /// Laravel may serialise integers as strings depending on the column type.
  static int? _toInt(dynamic value) => switch (value) {
    final int v => v,
    final num v => v.toInt(),
    final String v => int.tryParse(v),
    _ => null,
  };
}
