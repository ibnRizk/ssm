import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/features/order_tracking/domain/entities/order_status.dart';
import 'package:ssm/features/order_tracking/domain/entities/order_tracking.dart';
import 'package:ssm/features/order_tracking/domain/repos/order_tracking_repository.dart';
import 'package:ssm/features/order_tracking/presentation/cubit/order_tracking_cubit.dart';
import 'package:ssm/features/order_tracking/presentation/cubit/order_tracking_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository implements OrderTrackingRepository {
  Either<Failure, OrderSummary> summary = const Right<Failure, OrderSummary>(
    OrderSummary(id: 9, legacyStatus: 'pending'),
  );
  Either<Failure, List<OrderLine>> lines =
      const Right<Failure, List<OrderLine>>(<OrderLine>[
        OrderLine(name: 'Burger', quantity: 2, unitPrice: 20),
      ]);
  Either<Failure, OrderTracking> tracking = _tracking(OrderStatus.preparing);

  int trackingCalls = 0;
  int summaryCalls = 0;
  int otpCalls = 0;

  /// Completed by the test, so an OTP can be kept in flight.
  Completer<Either<Failure, DeliveryOtp>> otp = Completer();

  @override
  Future<Either<Failure, OrderSummary>> getSummary(int orderId) async {
    summaryCalls++;
    return summary;
  }

  @override
  Future<Either<Failure, List<OrderLine>>> getLines(int orderId) async => lines;

  @override
  Future<Either<Failure, OrderTracking>> getTracking(int orderId) async {
    trackingCalls++;
    return tracking;
  }

  @override
  Future<Either<Failure, DeliveryOtp>> requestDeliveryOtp(int orderId) {
    otpCalls++;
    return otp.future;
  }

  final List<String> cancelReasons = <String>[];

  /// Completed by the test, so a cancel can be kept in flight.
  Completer<Either<Failure, Unit>> cancel = Completer();

  @override
  Future<Either<Failure, Unit>> cancelOrder(
    int orderId, {
    required String reason,
  }) {
    cancelReasons.add(reason);
    return cancel.future;
  }
}

Either<Failure, OrderTracking> _tracking(OrderStatus? status) =>
    Right<Failure, OrderTracking>(OrderTracking(orderId: 9, status: status));

/// Stands in for [Timer.periodic]: the test fires [fire] by hand.
class _FakeTimer implements Timer {
  final void Function(Timer) onTick;
  bool cancelled = false;

  _FakeTimer(this.onTick);

  void fire() => onTick(this);

  @override
  void cancel() => cancelled = true;

  @override
  bool get isActive => !cancelled;

  @override
  int get tick => 0;
}

const DeliveryOtp _code = DeliveryOtp(code: '048213');

/// Lets async work the cubit started on its own run to completion.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late _FakeRepository repository;
  late List<_FakeTimer> timers;
  late OrderTrackingCubit cubit;

  setUp(() {
    repository = _FakeRepository();
    timers = <_FakeTimer>[];
    cubit = OrderTrackingCubit(
      orderId: 9,
      repository: repository,
      periodicTimer: (Duration interval, void Function(Timer) onTick) {
        expect(interval, OrderTrackingCubit.defaultPollInterval);
        final _FakeTimer timer = _FakeTimer(onTick);
        timers.add(timer);
        return timer;
      },
    );
  });

  tearDown(() => cubit.close());

  OrderTrackingLoaded loaded() => cubit.state as OrderTrackingLoaded;

  Future<void> poll() async {
    timers.single.fire();
    await _settle();
  }

  test('loads the order, its lines and live status, then polls', () async {
    await cubit.load();

    expect(loaded().status, OrderStatus.preparing);
    expect(loaded().lines, hasLength(1));
    expect(loaded().stale, isFalse);
    expect(timers, hasLength(1));
  });

  test('an order that is not yours is an error, with no polling', () async {
    repository.summary = const Left<Failure, OrderSummary>(NotFoundFailure());

    await cubit.load();

    expect(cubit.state, const OrderTrackingError(NotFoundFailure()));
    expect(timers, isEmpty);
  });

  test('without live status, the legacy one stands in as stale', () async {
    repository.summary = const Right<Failure, OrderSummary>(
      OrderSummary(id: 9, legacyStatus: 'canceled'),
    );
    repository.tracking = const Left<Failure, OrderTracking>(NetworkFailure());

    await cubit.load();

    expect(loaded().status, OrderStatus.cancelled);
    expect(loaded().stale, isTrue);
  });

  test('a null ssm_status reads as pending', () async {
    repository.tracking = _tracking(null);

    await cubit.load();

    expect(loaded().status, OrderStatus.pendingMerchant);
  });

  test('each poll moves the status along', () async {
    await cubit.load();

    repository.tracking = _tracking(OrderStatus.driverAccepted);
    await poll();

    expect(loaded().status, OrderStatus.driverAccepted);
  });

  test('a failed poll keeps the status and marks it stale', () async {
    await cubit.load();

    repository.tracking = const Left<Failure, OrderTracking>(NetworkFailure());
    await poll();

    expect(loaded().status, OrderStatus.preparing);
    expect(loaded().stale, isTrue);
    expect(timers.single.cancelled, isFalse, reason: 'keeps trying');
  });

  test('polling stops once the order is delivered', () async {
    await cubit.load();

    repository.tracking = _tracking(OrderStatus.delivered);
    await poll();

    expect(timers.single.cancelled, isTrue);
  });

  test('no courier yet keeps polling and catches a retried dispatch', () async {
    await cubit.load();
    repository.tracking = _tracking(OrderStatus.assignmentFailed);
    await poll();

    repository.tracking = _tracking(OrderStatus.driverAccepted);
    await poll();

    expect(timers.single.cancelled, isFalse);
    expect(loaded().status, OrderStatus.driverAccepted);
  });

  test('the new courier from a retried dispatch is shown', () async {
    await cubit.load();
    repository.tracking = _tracking(OrderStatus.assignmentFailed);
    await poll();

    repository.tracking = const Right<Failure, OrderTracking>(
      OrderTracking(
        orderId: 9,
        status: OrderStatus.driverAccepted,
        trackingAllowed: true,
        driverName: 'Khalid',
      ),
    );
    await poll();

    expect(loaded().tracking?.driverName, 'Khalid');
    expect(loaded().status.isLookingForCourier, isFalse);
  });

  test('no courier yet is shown as a wait, never as stale', () async {
    await cubit.load();

    repository.tracking = _tracking(OrderStatus.assignmentFailed);
    await poll();

    expect(loaded().status, OrderStatus.assignmentFailed);
    expect(loaded().status.isLookingForCourier, isTrue);
    expect(loaded().stale, isFalse);
  });

  test('a cancel by the store or a courier ends polling', () async {
    await cubit.load();

    repository.tracking = _tracking(OrderStatus.cancelled);
    await poll();

    expect(loaded().status, OrderStatus.cancelled);
    expect(timers.single.cancelled, isTrue);
  });

  group('before the merchant acts (ssm_status null)', () {
    setUp(() => repository.tracking = _tracking(null));

    // C1.1: a cancellation before the merchant acts only shows in the
    // legacy status, which used to be read once — the screen then said
    // "Order sent" and polled forever.
    test('a poll catches an early cancellation and stops', () async {
      await cubit.load();
      expect(loaded().status, OrderStatus.pendingMerchant);

      repository.summary = const Right<Failure, OrderSummary>(
        OrderSummary(id: 9, legacyStatus: 'canceled'),
      );
      await poll();

      expect(loaded().status, OrderStatus.cancelled);
      expect(timers.single.cancelled, isTrue);
    });

    test('each poll re-reads the legacy status', () async {
      await cubit.load();
      final int callsBefore = repository.summaryCalls;

      await poll();
      await poll();

      expect(repository.summaryCalls, callsBefore + 2);
    });

    test(
      'a failed legacy re-read keeps the status and marks it stale',
      () async {
        await cubit.load();

        repository.summary = const Left<Failure, OrderSummary>(
          NetworkFailure(),
        );
        await poll();

        expect(loaded().status, OrderStatus.pendingMerchant);
        expect(loaded().stale, isTrue);
        expect(timers.single.cancelled, isFalse, reason: 'keeps trying');
      },
    );
  });

  test('once ssm_status is known, polls skip the legacy status', () async {
    await cubit.load();
    final int callsBefore = repository.summaryCalls;

    await poll();

    expect(repository.summaryCalls, callsBefore);
  });

  test('closing the screen stops polling', () async {
    await cubit.load();

    await cubit.close();

    expect(timers.single.cancelled, isTrue);
  });

  group('app lifecycle', () {
    test('backgrounding stops polling', () async {
      await cubit.load();

      cubit.pausePolling();

      expect(timers.single.cancelled, isTrue);
    });

    test('foregrounding refreshes at once and polls again', () async {
      await cubit.load();
      cubit.pausePolling();
      final int callsBefore = repository.trackingCalls;

      repository.tracking = _tracking(OrderStatus.driverAccepted);
      await cubit.resumePolling();

      expect(repository.trackingCalls, callsBefore + 1);
      expect(loaded().status, OrderStatus.driverAccepted);
      expect(timers, hasLength(2));
      expect(timers.last.cancelled, isFalse);
    });

    test('resuming without a pause does nothing', () async {
      await cubit.load();
      final int callsBefore = repository.trackingCalls;

      await cubit.resumePolling();

      expect(repository.trackingCalls, callsBefore);
      expect(timers, hasLength(1));
    });

    test('a load finishing in the background does not start polling', () async {
      cubit.pausePolling();

      await cubit.load();

      expect(timers, isEmpty);
    });

    test('a final order is not refreshed on resume', () async {
      repository.tracking = _tracking(OrderStatus.delivered);
      await cubit.load();
      cubit.pausePolling();
      final int callsBefore = repository.trackingCalls;

      await cubit.resumePolling();

      expect(repository.trackingCalls, callsBefore);
      expect(timers, isEmpty);
    });

    test('resuming does not re-request a delivery OTP it has', () async {
      await cubit.load();
      repository.tracking = _tracking(OrderStatus.outForDelivery);
      await poll();
      repository.otp.complete(const Right<Failure, DeliveryOtp>(_code));
      await _settle();

      cubit.pausePolling();
      await cubit.resumePolling();

      expect(repository.otpCalls, 1);
      expect(loaded().otp, const OtpReady(_code));
    });
  });

  group('cancel order', () {
    setUp(() => repository.tracking = _tracking(null));

    test('sends the trimmed reason and shows the order cancelled', () async {
      await cubit.load();

      final Future<void> cancelling = cubit.cancelOrder(
        '  Ordered by mistake ',
      );
      expect(loaded().cancellation, const CancellationInProgress());
      repository.cancel.complete(const Right<Failure, Unit>(unit));
      await cancelling;

      expect(repository.cancelReasons, <String>['Ordered by mistake']);
      expect(loaded().status, OrderStatus.cancelled);
      expect(loaded().cancellation, const CancellationDone());
    });

    test('stops polling once cancelled', () async {
      await cubit.load();

      final Future<void> cancelling = cubit.cancelOrder('Changed my mind');
      repository.cancel.complete(const Right<Failure, Unit>(unit));
      await cancelling;

      expect(timers.single.cancelled, isTrue);
    });

    test('a poll that answers after the cancel does not undo it', () async {
      await cubit.load();
      final Future<void> cancelling = cubit.cancelOrder('Changed my mind');
      repository.cancel.complete(const Right<Failure, Unit>(unit));
      await cancelling;

      // The backend's legacy status may still say pending for a moment.
      await cubit.refresh();

      expect(loaded().status, OrderStatus.cancelled);
    });

    test('a refusal keeps the order and re-reads its status', () async {
      await cubit.load();
      final int callsBefore = repository.trackingCalls;

      repository.tracking = _tracking(OrderStatus.accepted);
      final Future<void> cancelling = cubit.cancelOrder('Too slow');
      repository.cancel.complete(
        const Left<Failure, Unit>(ForbiddenFailure(message: 'Not allowed')),
      );
      await cancelling;
      await _settle();

      expect(
        loaded().cancellation,
        const CancellationFailed(ForbiddenFailure(message: 'Not allowed')),
      );
      expect(repository.trackingCalls, callsBefore + 1);
      expect(loaded().status, OrderStatus.accepted);
    });

    test('a network failure keeps the order as it is', () async {
      await cubit.load();

      final Future<void> cancelling = cubit.cancelOrder('Too slow');
      repository.cancel.complete(const Left<Failure, Unit>(NetworkFailure()));
      await cancelling;

      expect(loaded().status, OrderStatus.pendingMerchant);
      expect(loaded().cancellation, const CancellationFailed(NetworkFailure()));
    });

    test('a second tap while cancelling sends nothing more', () async {
      await cubit.load();

      final Future<void> first = cubit.cancelOrder('Changed my mind');
      await cubit.cancelOrder('Changed my mind');
      repository.cancel.complete(const Right<Failure, Unit>(unit));
      await first;

      expect(repository.cancelReasons, hasLength(1));
    });

    test('is not sent once the merchant has accepted', () async {
      repository.tracking = _tracking(OrderStatus.accepted);
      await cubit.load();

      await cubit.cancelOrder('Changed my mind');

      expect(repository.cancelReasons, isEmpty);
    });

    test('is not sent without a reason', () async {
      await cubit.load();

      await cubit.cancelOrder('   ');

      expect(repository.cancelReasons, isEmpty);
    });

    // The legacy cancel leaves ssm_status at pending_merchant.
    test(
      'a cancel made elsewhere shows despite a pending ssm_status',
      () async {
        repository.tracking = _tracking(OrderStatus.pendingMerchant);
        await cubit.load();

        repository.summary = const Right<Failure, OrderSummary>(
          OrderSummary(id: 9, legacyStatus: 'canceled'),
        );
        await poll();

        expect(loaded().status, OrderStatus.cancelled);
        expect(timers.single.cancelled, isTrue);
      },
    );
  });

  group('delivery OTP', () {
    Future<void> goOutForDelivery() async {
      await cubit.load();
      repository.tracking = _tracking(OrderStatus.outForDelivery);
      await poll();
    }

    test('is requested once the order is out for delivery', () async {
      await cubit.load();
      expect(repository.otpCalls, 0);

      repository.tracking = _tracking(OrderStatus.outForDelivery);
      await poll();
      expect(loaded().otp, const OtpLoading());

      repository.otp.complete(const Right<Failure, DeliveryOtp>(_code));
      await _settle();
      expect(loaded().otp, const OtpReady(_code));
    });

    test('is requested on open when already out for delivery', () async {
      repository.tracking = _tracking(OrderStatus.outForDelivery);

      await cubit.load();

      expect(repository.otpCalls, 1);
      expect(loaded().otp, const OtpLoading());
    });

    test('is not re-requested by later polls', () async {
      await goOutForDelivery();
      repository.otp.complete(const Right<Failure, DeliveryOtp>(_code));
      await _settle();

      await poll();
      await poll();

      expect(repository.otpCalls, 1);
      expect(loaded().otp, const OtpReady(_code));
    });

    test('a 409 otp-not-available is shown as not ready', () async {
      await goOutForDelivery();

      repository.otp.complete(
        const Left<Failure, DeliveryOtp>(
          ConflictFailure(code: otpNotAvailableCode),
        ),
      );
      await _settle();

      expect(loaded().otp, const OtpUnavailable());
    });

    test('any other failure can be retried', () async {
      await goOutForDelivery();
      repository.otp.complete(
        const Left<Failure, DeliveryOtp>(NetworkFailure()),
      );
      await _settle();
      expect(loaded().otp, const OtpFailed(NetworkFailure()));

      repository.otp = Completer<Either<Failure, DeliveryOtp>>();
      final Future<void> retry = cubit.requestDeliveryOtp();
      repository.otp.complete(const Right<Failure, DeliveryOtp>(_code));
      await retry;

      expect(loaded().otp, const OtpReady(_code));
    });

    test('asking again while one is on its way sends nothing', () async {
      await goOutForDelivery();

      await cubit.requestDeliveryOtp();

      expect(repository.otpCalls, 1);
    });

    test('is never requested before out for delivery', () async {
      await cubit.load();

      await cubit.requestDeliveryOtp();

      expect(repository.otpCalls, 0);
    });

    test('is dropped once the order is delivered', () async {
      await goOutForDelivery();
      repository.otp.complete(const Right<Failure, DeliveryOtp>(_code));
      await _settle();

      repository.tracking = _tracking(OrderStatus.delivered);
      await poll();

      expect(loaded().otp, const OtpIdle());
    });

    test('a code arriving after delivery is ignored', () async {
      await goOutForDelivery();

      repository.tracking = _tracking(OrderStatus.delivered);
      await poll();
      repository.otp.complete(const Right<Failure, DeliveryOtp>(_code));
      await _settle();

      expect(loaded().status, OrderStatus.delivered);
      expect(loaded().otp, const OtpIdle());
    });
  });
}
