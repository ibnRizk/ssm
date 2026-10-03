import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/order_tracking.dart';

sealed class OrderTrackingState extends Equatable {
  const OrderTrackingState();

  @override
  List<Object?> get props => [];
}

final class OrderTrackingLoading extends OrderTrackingState {
  const OrderTrackingLoading();
}

/// The order itself couldn't be loaded ([NotFoundFailure]: not the
/// customer's, or gone).
final class OrderTrackingError extends OrderTrackingState {
  final Failure failure;

  const OrderTrackingError(this.failure);

  @override
  List<Object?> get props => [failure];
}

final class OrderTrackingLoaded extends OrderTrackingState {
  final OrderSummary summary;
  final List<OrderLine> lines;

  /// The latest live tracking; null until it first loads.
  final OrderTracking? tracking;
  final OrderStatus status;
  final DeliveryOtpState otp;

  /// The last status refresh failed — [status] may be behind. Polling
  /// keeps trying.
  final bool stale;

  const OrderTrackingLoaded({
    required this.summary,
    required this.lines,
    required this.status,
    this.tracking,
    this.otp = const OtpIdle(),
    this.stale = false,
  });

  OrderTrackingLoaded copyWith({
    OrderSummary? summary,
    OrderTracking? tracking,
    OrderStatus? status,
    DeliveryOtpState? otp,
    bool? stale,
  }) => OrderTrackingLoaded(
    summary: summary ?? this.summary,
    lines: lines,
    tracking: tracking ?? this.tracking,
    status: status ?? this.status,
    otp: otp ?? this.otp,
    stale: stale ?? this.stale,
  );

  @override
  List<Object?> get props => [summary, lines, tracking, status, otp, stale];
}

/// The delivery OTP, only relevant while the order is out for delivery.
sealed class DeliveryOtpState extends Equatable {
  const DeliveryOtpState();

  @override
  List<Object?> get props => [];
}

final class OtpIdle extends DeliveryOtpState {
  const OtpIdle();
}

final class OtpLoading extends DeliveryOtpState {
  const OtpLoading();
}

final class OtpReady extends DeliveryOtpState {
  final DeliveryOtp otp;

  const OtpReady(this.otp);

  @override
  List<Object?> get props => [otp];
}

/// The backend answered 409 `otp-not-available` — the order isn't out for
/// delivery on its side (yet).
final class OtpUnavailable extends DeliveryOtpState {
  const OtpUnavailable();
}

final class OtpFailed extends DeliveryOtpState {
  final Failure failure;

  const OtpFailed(this.failure);

  @override
  List<Object?> get props => [failure];
}
