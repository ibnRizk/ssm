import 'package:equatable/equatable.dart';

/// The first page of `GET /customer/loyalty/history` — one entry per
/// delivered order that counted towards progress. Only the counts are used
/// (the "latest completed orders" row shows one "+1" tile per entry).
class LoyaltyHistory extends Equatable {
  /// Entries across all pages.
  final int total;

  /// Entries on the first page, newest first.
  final int recentCount;

  const LoyaltyHistory({required this.total, required this.recentCount});

  @override
  List<Object?> get props => [total, recentCount];
}
