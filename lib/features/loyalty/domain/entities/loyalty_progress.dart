import 'package:equatable/equatable.dart';

/// Progress towards the next free delivery. One delivered order is one step.
class LoyaltyProgress extends Equatable {
  final int currentProgress;
  final int eligibleOrdersRequired;

  /// As computed server-side — `max(0, required - current)`.
  final int ordersRemainingForNextReward;

  /// Free deliveries earned and not yet used.
  final int availableFreeDeliveries;

  const LoyaltyProgress({
    required this.currentProgress,
    required this.eligibleOrdersRequired,
    required this.ordersRemainingForNextReward,
    required this.availableFreeDeliveries,
  });

  /// 0–100. Zero when no target is configured, rather than dividing by zero.
  int get percent {
    if (eligibleOrdersRequired <= 0) return 0;
    return (currentProgress / eligibleOrdersRequired * 100).round().clamp(
      0,
      100,
    );
  }

  @override
  List<Object?> get props => [
    currentProgress,
    eligibleOrdersRequired,
    ordersRemainingForNextReward,
    availableFreeDeliveries,
  ];
}
