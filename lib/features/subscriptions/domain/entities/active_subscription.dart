import 'package:equatable/equatable.dart';

/// The customer's currently active (paid and approved) subscription.
/// Pending purchase intents are not "active" and never appear here.
class ActiveSubscription extends Equatable {
  final int id;
  final int deliveriesTotal;
  final int deliveriesRemaining;

  /// Null when the backend omits or garbles `expires_at`.
  final DateTime? expiresAt;

  /// Null when the response doesn't embed the plan.
  final String? planName;

  const ActiveSubscription({
    required this.id,
    required this.deliveriesTotal,
    required this.deliveriesRemaining,
    this.expiresAt,
    this.planName,
  });

  @override
  List<Object?> get props => [
    id,
    deliveriesTotal,
    deliveriesRemaining,
    expiresAt,
    planName,
  ];
}
