import '../../../../core/api/json_readers.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/loyalty_progress.dart';

/// `GET /customer/loyalty` → `{ "data": { current_progress,
/// eligible_orders_required, orders_remaining_for_next_reward,
/// available_free_deliveries, lifetime_* } }`. Deliberately not the legacy
/// `loyalty_point` field on `/customer/info`, which the API guide says to
/// ignore.
class LoyaltyProgressModel extends LoyaltyProgress {
  const LoyaltyProgressModel({
    required super.currentProgress,
    required super.eligibleOrdersRequired,
    required super.ordersRemainingForNextReward,
    required super.availableFreeDeliveries,
  });

  /// Throws [ServerException] when the body lacks any of the four fields.
  factory LoyaltyProgressModel.fromJson(dynamic json) {
    final dynamic data = json is Map ? json['data'] : null;
    if (data is! Map) throw const ServerException();
    final int? current = jsonInt(data['current_progress']);
    final int? target = jsonInt(data['eligible_orders_required']);
    final int? remaining = jsonInt(data['orders_remaining_for_next_reward']);
    final int? free = jsonInt(data['available_free_deliveries']);
    if (current == null ||
        target == null ||
        remaining == null ||
        free == null) {
      throw const ServerException();
    }
    return LoyaltyProgressModel(
      currentProgress: current,
      eligibleOrdersRequired: target,
      ordersRemainingForNextReward: remaining,
      availableFreeDeliveries: free,
    );
  }
}
