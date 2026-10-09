import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/realtime/realtime_event.dart';
import '../../../../core/realtime/realtime_repository.dart';
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

  /// With [realtime], the screen also refreshes the moment the server
  /// reports a change to this order (status, driver, driver location),
  /// instead of waiting for the next poll. Polling stays as the fallback
  /// for when the socket is down or unconfigured.
  OrderTrackingCubit({
    required this.orderId,
    required this.repository,
    RealtimeRepository? realtime,
    this.pollInterval = defaultPollInterval,
    PeriodicTimerFactory periodicTimer = Timer.periodic,
  }) : _realtime = realtime,
       _periodicTimer = periodicTimer,
       super(const OrderTrackingLoading()) {
    if (realtime == null) return;
    // Driver location frames only come on the order's own channel.
    realtime.watchOrder(orderId);
    _realtimeSub = realtime.events
        .where(_concernsThisOrder)
        .listen((_) => refresh());
  }

  static const Duration defaultPollInterval = Duration(seconds: 15);

  final RealtimeRepository? _realtime;
  StreamSubscription<RealtimeEvent>? _realtimeSub;

  bool _concernsThisOrder(RealtimeEvent event) => switch (event) {
    OrderRealtimeEvent(orderId: final int id) => id == orderId,
    RealtimeReconnected() => true,
    NotificationCreated() || ParcelRealtimeEvent() => false,
  };

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
  ///
  /// While `ssm_status` is still null or pending, the legacy summary is
  /// re-read too: until the merchant acts, it's the only place a
  /// cancellation shows (see [OrderStatus.resolve]).
  Future<void> refresh() async {
    if (_refreshing || state is! OrderTrackingLoaded) return;
    _refreshing = true;
    try {
      final Either<Failure, OrderTracking> result = await repository
          .getTracking(orderId);
      final Either<Failure, OrderSummary>? legacy = switch (result) {
        Right<Failure, OrderTracking>(
          value: OrderTracking(status: null || OrderStatus.pendingMerchant),
        ) =>
          await repository.getSummary(orderId),
        _ => null,
      };
      final OrderTrackingState current = state;
      if (isClosed || current is! OrderTrackingLoaded) return;
      // Nothing changes after a final status — and an answer that left
      // before a cancel went through must not undo it.
      if (current.status.isFinal) return;
      result.fold((_) => emit(current.copyWith(stale: true)), (
        OrderTracking live,
      ) {
        // A failed re-read keeps the last summary, flagged as stale.
        final OrderSummary? fresh = legacy?.fold((_) => null, (s) => s);
        final OrderSummary summary = fresh ?? current.summary;
        final OrderStatus status = OrderStatus.resolve(
          live.status,
          summary.legacyStatus,
        );
        emit(
          current.copyWith(
            summary: summary,
            tracking: live,
            status: status,
            stale: legacy != null && fresh == null,
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

  /// Cancels the order with the customer's [reason]. Only while it can
  /// still be cancelled, and not while a cancel is on its way. A refusal
  /// (the merchant accepted meanwhile) re-reads the status to show why.
  Future<void> cancelOrder(String reason) async {
    final OrderTrackingState current = state;
    final String trimmed = reason.trim();
    if (current is! OrderTrackingLoaded ||
        !current.status.canBeCancelled ||
        current.cancellation is CancellationInProgress ||
        trimmed.isEmpty) {
      return;
    }
    emit(current.copyWith(cancellation: const CancellationInProgress()));
    final Either<Failure, Unit> result = await repository.cancelOrder(
      orderId,
      reason: trimmed,
    );
    final OrderTrackingState latest = state;
    if (isClosed || latest is! OrderTrackingLoaded) return;
    result.fold(
      (Failure failure) {
        emit(latest.copyWith(cancellation: CancellationFailed(failure)));
        if (failure is ForbiddenFailure) unawaited(refresh());
      },
      (_) {
        // The server confirmed it; its legacy status may lag a poll behind.
        emit(
          latest.copyWith(
            status: OrderStatus.cancelled,
            otp: const OtpIdle(),
            cancellation: const CancellationDone(),
          ),
        );
        _afterStatusChange();
      },
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
  Future<void> close() async {
    _timer?.cancel();
    await _realtimeSub?.cancel();
    _realtime?.unwatchOrder(orderId);
    return super.close();
  }
}
