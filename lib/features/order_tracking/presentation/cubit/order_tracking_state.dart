import 'package:equatable/equatable.dart';

import '../../../../core/delivery_otp/delivery_otp.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/order_tracking.dart';

export '../../../../core/delivery_otp/delivery_otp.dart';

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

  /// The customer's cancel request, if any — see [OrderStatus.canBeCancelled].
  final OrderCancellation cancellation;

  /// The last status refresh failed — [status] may be behind. Polling
  /// keeps trying.
  final bool stale;

  const OrderTrackingLoaded({
    required this.summary,
    required this.lines,
    required this.status,
    this.tracking,
    this.otp = const OtpIdle(),
    this.cancellation = const CancellationIdle(),
    this.stale = false,
  });

  OrderTrackingLoaded copyWith({
    OrderSummary? summary,
    OrderTracking? tracking,
    OrderStatus? status,
    DeliveryOtpState? otp,
    OrderCancellation? cancellation,
    bool? stale,
  }) => OrderTrackingLoaded(
    summary: summary ?? this.summary,
    lines: lines,
    tracking: tracking ?? this.tracking,
    status: status ?? this.status,
    otp: otp ?? this.otp,
    cancellation: cancellation ?? this.cancellation,
    stale: stale ?? this.stale,
  );

  @override
  List<Object?> get props => [
    summary,
    lines,
    tracking,
    status,
    otp,
    cancellation,
    stale,
  ];
}

sealed class OrderCancellation extends Equatable {
  const OrderCancellation();

  @override
  List<Object?> get props => [];
}

final class CancellationIdle extends OrderCancellation {
  const CancellationIdle();
}

final class CancellationInProgress extends OrderCancellation {
  const CancellationInProgress();
}

/// The order is cancelled — the screen confirms it once.
final class CancellationDone extends OrderCancellation {
  const CancellationDone();
}

/// Refused ([ForbiddenFailure]: the merchant already accepted) or not
/// sent. The order stays as it is.
final class CancellationFailed extends OrderCancellation {
  final Failure failure;

  const CancellationFailed(this.failure);

  @override
  List<Object?> get props => [failure];
}
