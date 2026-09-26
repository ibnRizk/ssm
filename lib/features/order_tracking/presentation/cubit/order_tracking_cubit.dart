import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/order_tracking.dart';
import '../../domain/repos/order_tracking_repository.dart';
import 'order_tracking_state.dart';

/// Makes a periodic timer; swapped in tests to fire ticks by hand.
typedef PeriodicTimerFactory =
    Timer Function(Duration interval, void Function(Timer) onTick);

/// Screen-scoped (one per tracking route). Loads the order, then polls the
/// canonical status until it's final. While the order is out for delivery
/// it fetches the delivery OTP once — requesting again invalidates the
/// code the customer may already have read out, so a new one is only
/// requested when the customer asks ([requestDeliveryOtp]).
class OrderTrackingCubit extends Cubit<OrderTrackingState> {
  final int orderId;
  final OrderTrackingRepository repository;
  final Duration pollInterval;
  final PeriodicTimerFactory _periodicTimer;

  OrderTrackingCubit({
    required this.orderId,
    required this.repository,
    this.pollInterval = defaultPollInterval,
    PeriodicTimerFactory periodicTimer = Timer.periodic,
  }) : _periodicTimer = periodicTimer,
       super(const OrderTrackingLoading());

  static const Duration defaultPollInterval = Duration(seconds: 15);

  Timer? _timer;
  bool _refreshing = false;
  bool _paused = false;

  /// The summary, lines and live status, concurrently. Without the order
  /// itself there's nothing to show; without the live status, the legacy
  /// one stands in and polling catches up.
  Future<void> load() async {
    emit(const OrderTrackingLoading());
    final (
      Either<Failure, OrderSummary> summary,
      Either<Failure, List<OrderLine>> lines,
      Either<Failure, OrderTracking> tracking,
    ) = await (
      repository.getSummary(orderId),
      repository.getLines(orderId),
      repository.getTracking(orderId),
    ).wait;
    if (isClosed) return;

    final Either<Failure, (OrderSummary, List<OrderLine>)> order = summary
        .flatMap((OrderSummary s) => lines.map((List<OrderLine> l) => (s, l)));
    if (order case Left<Failure, (OrderSummary, List<OrderLine>)>(
      :final Failure value,
    )) {
      emit(OrderTrackingError(value));
      return;
    }
    final (OrderSummary details, List<OrderLine> items) = order.getOrElse(
      () => throw StateError('unreachable: Left handled above'),
    );
    final OrderTracking? live = tracking.fold(
      (_) => null,
      (OrderTracking t) => t,
    );
    emit(
      OrderTrackingLoaded(
        summary: details,
        lines: items,
        tracking: live,
        status: OrderStatus.resolve(live?.status, details.legacyStatus),
        stale: live == null,
      ),
    );
    if (isClosed) return;
    _afterStatusChange();
  }

  /// Re-reads the live status — the poll, and pull-to-refresh. Skipped
  /// while one is already in flight.
  Future<void> refresh() async {
    if (_refreshing || state is! OrderTrackingLoaded) return;
    _refreshing = true;
    try {
      final Either<Failure, OrderTracking> result = await repository
          .getTracking(orderId);
      final OrderTrackingState current = state;
      if (isClosed || current is! OrderTrackingLoaded) return;
      result.fold((_) => emit(current.copyWith(stale: true)), (
        OrderTracking live,
      ) {
        final OrderStatus status = OrderStatus.resolve(
          live.status,
          current.summary.legacyStatus,
        );
        emit(
          current.copyWith(
            tracking: live,
            status: status,
            stale: false,
            // A code only means something while the courier is on the way.
            otp: status.needsDeliveryOtp ? current.otp : const OtpIdle(),
          ),
        );
      });
      if (isClosed) return;
      _afterStatusChange();
    } finally {
      _refreshing = false;
    }
  }

  /// Stops polling while the app is in the background. The delivery OTP
  /// is left as it is.
  void pausePolling() {
    _paused = true;
    _timer?.cancel();
    _timer = null;
  }

  /// Back in the foreground: catches up at once, then polls again (the
  /// refresh restarts the timer unless the order went final meanwhile).
  Future<void> resumePolling() async {
    if (!_paused) return;
    _paused = false;
    final OrderTrackingState current = state;
    if (isClosed || current is! OrderTrackingLoaded) return;
    if (current.status.isFinal) return;
    await refresh();
  }

  /// Fetches a delivery OTP (a new one replaces the old). Only while the
  /// order is out for delivery, and not while one is on its way.
  Future<void> requestDeliveryOtp() async {
    final OrderTrackingState current = state;
    if (current is! OrderTrackingLoaded ||
        !current.status.needsDeliveryOtp ||
        current.otp is OtpLoading) {
      return;
    }
    emit(current.copyWith(otp: const OtpLoading()));
    final Either<Failure, DeliveryOtp> result = await repository
        .requestDeliveryOtp(orderId);
    final OrderTrackingState latest = state;
    // The order may have moved on (delivered) while the code was coming.
    if (isClosed ||
        latest is! OrderTrackingLoaded ||
        !latest.status.needsDeliveryOtp) {
      return;
    }
    emit(
      latest.copyWith(
        otp: result.fold(
          (Failure failure) => failure is ConflictFailure
              ? const OtpUnavailable()
              : OtpFailed(failure),
          OtpReady.new,
        ),
      ),
    );
  }

  /// Polls until the status is final (not while paused), and fetches the
  /// first delivery OTP once the order is out for delivery.
  void _afterStatusChange() {
    final OrderTrackingState current = state;
    if (current is! OrderTrackingLoaded) return;
    if (current.status.isFinal) {
      _timer?.cancel();
      _timer = null;
    } else if (!_paused) {
      _timer ??= _periodicTimer(pollInterval, (_) => refresh());
    }
    if (current.status.needsDeliveryOtp && current.otp is OtpIdle) {
      unawaited(requestDeliveryOtp());
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
