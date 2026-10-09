import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/delivery_otp/delivery_otp.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/core/location/geo_point.dart';
import 'package:ssm/core/realtime/realtime_event.dart';
import 'package:ssm/features/c2c_parcels/domain/entities/c2c_parcel.dart';
import 'package:ssm/features/c2c_parcels/domain/entities/c2c_parcel_status.dart';
import 'package:ssm/features/c2c_parcels/presentation/cubit/c2c_parcel_tracking_cubit.dart';
import 'package:ssm/features/c2c_parcels/presentation/cubit/c2c_parcel_tracking_state.dart';

import '../../helpers/fake_realtime_repository.dart';
import 'fake_c2c_parcels_repository.dart';

const int _id = 12;

C2cParcelDetails _parcel({
  C2cParcelStatus status = C2cParcelStatus.dispatching,
  int version = 3,
  C2cViewerRole role = C2cViewerRole.sender,
  C2cParcelActions actions = const C2cParcelActions(
    canCancel: true,
    canRetryDispatch: true,
    canRequestDeliveryOtp: true,
    canRequestReturnOtp: true,
    canOpenSupportCase: true,
  ),
}) => C2cParcelDetails(
  id: _id,
  reference: 'C2C-1',
  viewerRole: role,
  status: status,
  statusVersion: version,
  item: const C2cParcelItem(title: 'Gift'),
  sender: const C2cParty(),
  recipient: const C2cParty(),
  actions: actions,
);

C2cParcelTracking _tracking({
  C2cParcelStatus status = C2cParcelStatus.dispatching,
  int version = 3,
  int? interval = 15,
}) => C2cParcelTracking(
  status: status,
  statusVersion: version,
  isTerminal: status.isTerminal,
  pollingIntervalSeconds: interval,
);

/// A periodic timer the test fires by hand.
class _ManualTimer implements Timer {
  final Duration interval;
  final void Function(Timer) onTick;
  bool cancelled = false;

  _ManualTimer(this.interval, this.onTick);

  void fire() => onTick(this);

  @override
  void cancel() => cancelled = true;

  @override
  bool get isActive => !cancelled;

  @override
  int get tick => 0;
}

void main() {
  late FakeC2cParcelsRepository repository;
  late FakeRealtimeRepository realtime;
  late List<_ManualTimer> timers;
  late C2cParcelTrackingCubit cubit;
  late int keys;
  late DateTime clock;

  C2cParcelDetails details = _parcel();
  C2cParcelTracking tracking = _tracking();

  setUp(() {
    details = _parcel();
    tracking = _tracking();
    clock = DateTime.utc(2026, 10, 9, 12);
    repository = FakeC2cParcelsRepository()
      ..onDetails = (() async => Right(details))
      ..onTracking = (() async => Right(tracking));
    realtime = FakeRealtimeRepository();
    timers = <_ManualTimer>[];
    keys = 0;
    cubit = C2cParcelTrackingCubit(
      parcelId: _id,
      repository: repository,
      realtime: realtime,
      periodicTimer: (Duration interval, void Function(Timer) onTick) {
        final _ManualTimer timer = _ManualTimer(interval, onTick);
        timers.add(timer);
        return timer;
      },
      newIdempotencyKey: () => 'key-${++keys}',
      now: () => clock,
    );
  });

  tearDown(() => cubit.close());

  C2cTrackingLoaded loaded() => cubit.state as C2cTrackingLoaded;
  _ManualTimer liveTimer() =>
      timers.lastWhere((_ManualTimer t) => !t.cancelled);

  group('load', () {
    test('watches the parcel channel from the start', () {
      expect(realtime.watchedParcels, <int>[_id]);
    });

    test('shows details and live view', () async {
      await cubit.load();

      expect(loaded().details, details);
      expect(loaded().tracking, tracking);
    });

    test('works from the details alone when the live view fails', () async {
      repository.onTracking = () async => const Left(NetworkFailure());

      await cubit.load();

      expect(loaded().tracking, isNull);
    });

    test('a parcel that is not yours is an error', () async {
      repository.onDetails = () async => const Left(NotFoundFailure());

      await cubit.load();

      expect(cubit.state, const C2cTrackingError(NotFoundFailure()));
    });

    test('polls at the server interval', () async {
      tracking = _tracking(interval: 20);

      await cubit.load();

      expect(liveTimer().interval, const Duration(seconds: 20));
    });

    test('a final parcel is not polled', () async {
      details = _parcel(status: C2cParcelStatus.delivered);
      tracking = _tracking(status: C2cParcelStatus.delivered, interval: null);

      await cubit.load();

      expect(timers, isEmpty);
    });
  });

  group('tracking channel', () {
    test('not watched while looking for a driver', () async {
      await cubit.load();

      expect(realtime.watchedParcelTracking, isEmpty);
    });

    test('watched once the sender may see the driver', () async {
      details = _parcel(status: C2cParcelStatus.driverAccepted);

      await cubit.load();

      expect(realtime.watchedParcelTracking, <int>[_id]);
    });

    test('a recipient waits until pickup', () async {
      details = _parcel(
        status: C2cParcelStatus.driverAccepted,
        role: C2cViewerRole.recipient,
      );

      await cubit.load();

      expect(realtime.watchedParcelTracking, isEmpty);
    });

    test('unwatched when the parcel is delivered', () async {
      details = _parcel(status: C2cParcelStatus.outForDelivery, version: 8);
      await cubit.load();

      details = _parcel(status: C2cParcelStatus.delivered, version: 9);
      await cubit.refresh();

      expect(realtime.unwatchedParcelTracking, <int>[_id]);
    });

    test('closing unwatches both channels', () async {
      details = _parcel(status: C2cParcelStatus.pickedUp);
      await cubit.load();

      await cubit.close();

      expect(realtime.unwatchedParcels, <int>[_id]);
      expect(realtime.unwatchedParcelTracking, <int>[_id]);
    });
  });

  group('realtime', () {
    test('a newer status refetches', () async {
      await cubit.load();
      details = _parcel(status: C2cParcelStatus.driverAccepted, version: 5);

      realtime.emit(const ParcelStatusChanged(_id, statusVersion: 5));
      await pumpEventQueue();

      expect(loaded().details.status, C2cParcelStatus.driverAccepted);
    });

    test('a version already shown is ignored', () async {
      await cubit.load();
      final int before = repository.detailsCalls;

      realtime.emit(const ParcelStatusChanged(_id, statusVersion: 3));
      await pumpEventQueue();

      expect(repository.detailsCalls, before);
    });

    test("another parcel's event is ignored", () async {
      await cubit.load();
      final int before = repository.detailsCalls;

      realtime.emit(const ParcelStatusChanged(99, statusVersion: 50));
      await pumpEventQueue();

      expect(repository.detailsCalls, before);
    });

    test('a driver position moves the map without a refetch', () async {
      details = _parcel(status: C2cParcelStatus.outForDelivery);
      tracking = _tracking(status: C2cParcelStatus.outForDelivery);
      await cubit.load();
      final int before = repository.trackingCalls;

      realtime.emit(
        const ParcelDriverLocationUpdated(
          _id,
          location: GeoPoint(latitude: 30.05, longitude: 31.24),
        ),
      );

      expect(
        loaded().tracking!.driverLocation!.point,
        const GeoPoint(latitude: 30.05, longitude: 31.24),
      );
      expect(repository.trackingCalls, before);
    });

    test('a reconnect catches up', () async {
      await cubit.load();
      final int before = repository.detailsCalls;

      realtime.emit(const RealtimeReconnected());
      await pumpEventQueue();

      expect(repository.detailsCalls, before + 1);
    });

    test('a status event during a refresh is not lost', () async {
      await cubit.load();
      final Completer<Either<Failure, C2cParcelDetails>> inFlightRead =
          Completer<Either<Failure, C2cParcelDetails>>();
      repository.onDetails = () => inFlightRead.future;
      final Future<void> inFlight = cubit.refresh();

      // The parcel moves on after the in-flight read was already answered.
      realtime.emit(const ParcelStatusChanged(_id, statusVersion: 5));
      repository.onDetails = () async =>
          Right(_parcel(status: C2cParcelStatus.driverAccepted, version: 5));
      inFlightRead.complete(Right(_parcel()));
      await inFlight;

      expect(loaded().details.status, C2cParcelStatus.driverAccepted);
    });

    test('an older driver position never moves the driver back', () async {
      details = _parcel(status: C2cParcelStatus.outForDelivery);
      tracking = _tracking(status: C2cParcelStatus.outForDelivery);
      await cubit.load();
      final DateTime at = DateTime.utc(2026, 10, 9, 12, 0, 10);

      realtime
        ..emit(
          ParcelDriverLocationUpdated(
            _id,
            location: const GeoPoint(latitude: 30.05, longitude: 31.24),
            recordedAt: at,
          ),
        )
        ..emit(
          ParcelDriverLocationUpdated(
            _id,
            location: const GeoPoint(latitude: 30.01, longitude: 31.20),
            recordedAt: at.subtract(const Duration(seconds: 5)),
          ),
        );

      expect(
        loaded().tracking!.driverLocation!.point,
        const GeoPoint(latitude: 30.05, longitude: 31.24),
      );
    });

    test('a stale refetch never steps back a version', () async {
      details = _parcel(status: C2cParcelStatus.pickedUp, version: 7);
      await cubit.load();

      details = _parcel(status: C2cParcelStatus.driverAtPickup, version: 6);
      await cubit.refresh();

      expect(loaded().details.statusVersion, 7);
    });
  });

  group('polling fallback', () {
    test('polls only while the socket is down', () async {
      await cubit.load();
      final int before = repository.trackingCalls;

      realtime.connected = true;
      liveTimer().fire();
      await pumpEventQueue();
      expect(repository.trackingCalls, before);

      realtime.connected = false;
      liveTimer().fire();
      await pumpEventQueue();
      expect(repository.trackingCalls, before + 1);
    });

    test('a connected socket still syncs a quiet parcel every minute', () async {
      // Its channel's authorization may have failed: no event would come.
      await cubit.load();
      realtime.connected = true;
      final int before = repository.trackingCalls;

      clock = clock.add(const Duration(seconds: 30));
      liveTimer().fire();
      await pumpEventQueue();
      expect(repository.trackingCalls, before);

      clock = clock.add(const Duration(seconds: 31));
      liveTimer().fire();
      await pumpEventQueue();
      expect(repository.trackingCalls, before + 1);
    });

    test('an event for the parcel proves the channel works', () async {
      await cubit.load();
      realtime.connected = true;
      final int before = repository.trackingCalls;

      clock = clock.add(const Duration(seconds: 40));
      realtime.emit(const ParcelStatusChanged(_id, statusVersion: 3));
      clock = clock.add(const Duration(seconds: 30));
      liveTimer().fire();
      await pumpEventQueue();

      expect(repository.trackingCalls, before);
    });

    test('a poll that reveals a newer status refetches the details', () async {
      await cubit.load();
      final int before = repository.detailsCalls;
      details = _parcel(status: C2cParcelStatus.driverAccepted, version: 5);
      tracking = _tracking(status: C2cParcelStatus.driverAccepted, version: 5);

      liveTimer().fire();
      await pumpEventQueue();

      expect(repository.detailsCalls, before + 1);
      expect(loaded().details.status, C2cParcelStatus.driverAccepted);
    });

    test('pausing stops the timer; resuming catches up', () async {
      await cubit.load();

      cubit.pausePolling();
      expect(timers.every((_ManualTimer t) => t.cancelled), isTrue);

      final int before = repository.detailsCalls;
      await cubit.resumePolling();
      expect(repository.detailsCalls, before + 1);
      expect(liveTimer().cancelled, isFalse);
    });
  });

  group('commands', () {
    test('cancel sends the version shown, then refetches', () async {
      await cubit.load();
      repository.onCommand = () async => const Right(unit);
      final int before = repository.detailsCalls;

      await cubit.cancel(C2cCancelReason.senderCancelled);

      expect(repository.commands.single, ('cancel', 3, 'key-1'));
      expect(loaded().command, const C2cCommandDone(C2cCommand.cancel));
      expect(repository.detailsCalls, before + 1);
    });

    test('a recipient cannot cancel', () async {
      details = _parcel(role: C2cViewerRole.recipient);
      await cubit.load();

      await cubit.cancel(C2cCancelReason.senderCancelled);

      expect(repository.commands, isEmpty);
    });

    test('no cancel after pickup', () async {
      details = _parcel(status: C2cParcelStatus.pickedUp);
      await cubit.load();

      await cubit.cancel(C2cCancelReason.senderCancelled);

      expect(repository.commands, isEmpty);
    });

    test('stale_version refreshes and reports', () async {
      await cubit.load();
      const ConflictFailure stale = ConflictFailure(
        code: C2cParcelErrorCode.staleVersion,
      );
      repository.onCommand = () async => const Left(stale);
      details = _parcel(status: C2cParcelStatus.driverAccepted, version: 5);

      await cubit.cancel(C2cCancelReason.senderCancelled);

      expect(
        loaded().command,
        const C2cCommandFailed(C2cCommand.cancel, stale),
      );
      expect(loaded().details.statusVersion, 5);
    });

    test('a lost answer is retried with the same key', () async {
      await cubit.load();
      repository.onCommand = () async => const Left(NetworkFailure());
      await cubit.cancel(C2cCancelReason.senderCancelled);
      cubit.clearCommand();

      repository.onCommand = () async => const Right(unit);
      await cubit.cancel(C2cCancelReason.senderCancelled);

      expect(repository.commands.map((c) => c.$3), <String>['key-1', 'key-1']);
    });

    test('a retry with a different reason gets a new key', () async {
      // The old key with a changed body would be an idempotency_conflict.
      await cubit.load();
      repository.onCommand = () async => const Left(NetworkFailure());
      await cubit.cancel(C2cCancelReason.wrongAddress);
      cubit.clearCommand();

      await cubit.cancel(C2cCancelReason.other);

      expect(repository.commands.map((c) => c.$3), <String>['key-1', 'key-2']);
    });

    test('a lost support case is retried with the same key', () async {
      await cubit.load();
      repository.onCommand = () async => const Left(NetworkFailure());
      await cubit.openSupportCase(C2cSupportReason.other, 'Driver is late');
      cubit.clearCommand();

      await cubit.openSupportCase(C2cSupportReason.other, ' Driver is late ');

      expect(repository.commands.map((c) => c.$3), <String>['key-1', 'key-1']);
    });

    test('any refusal re-reads the parcel, not only stale_version', () async {
      await cubit.load();
      repository.onCommand = () async => const Left(
        ServerFailure(code: C2cParcelErrorCode.cancelNotAllowedAfterPickup),
      );
      details = _parcel(status: C2cParcelStatus.pickedUp, version: 6);

      await cubit.cancel(C2cCancelReason.senderCancelled);

      expect(loaded().details.status, C2cParcelStatus.pickedUp);
      expect(loaded().details.canCancel, isFalse);
    });

    test('a lost answer does not re-read', () async {
      await cubit.load();
      repository.onCommand = () async => const Left(NetworkFailure());
      final int before = repository.detailsCalls;

      await cubit.cancel(C2cCancelReason.senderCancelled);

      expect(repository.detailsCalls, before);
    });

    test('a refused command frees its key', () async {
      await cubit.load();
      repository.onCommand = () async =>
          const Left(ServerFailure(code: C2cParcelErrorCode.invalidTransition));
      await cubit.cancel(C2cCancelReason.senderCancelled);
      cubit.clearCommand();

      await cubit.cancel(C2cCancelReason.senderCancelled);

      expect(repository.commands.map((c) => c.$3), <String>['key-1', 'key-2']);
    });

    test('one command at a time', () async {
      await cubit.load();
      final Completer<Either<Failure, Unit>> pending =
          Completer<Either<Failure, Unit>>();
      repository.onCommand = () => pending.future;

      final Future<void> first = cubit.cancel(C2cCancelReason.other);
      await cubit.openSupportCase(C2cSupportReason.other, 'Driver is late');
      pending.complete(const Right(unit));
      await first;

      expect(repository.commands, hasLength(1));
    });

    test('retry dispatch only after no driver was found', () async {
      await cubit.load();
      await cubit.retryDispatch();
      expect(repository.commands, isEmpty);

      details = _parcel(status: C2cParcelStatus.assignmentFailed, version: 4);
      await cubit.refresh();
      repository.onCommand = () async => const Right(unit);
      await cubit.retryDispatch();

      expect(repository.commands.single, ('retry', 4, 'key-1'));
    });

    test('a support case needs five characters', () async {
      await cubit.load();

      await cubit.openSupportCase(C2cSupportReason.other, ' hi ');

      expect(repository.commands, isEmpty);
    });
  });

  group('requestOtp', () {
    test('shows the code while out for delivery', () async {
      details = _parcel(status: C2cParcelStatus.outForDelivery, version: 8);
      await cubit.load();
      repository.onOtp = () async => const Right(
        C2cParcelOtp(code: '482913', purpose: C2cOtpPurpose.delivery),
      );

      await cubit.requestOtp();

      expect(loaded().otp, const OtpReady(DeliveryOtp(code: '482913')));
    });

    test('not before the parcel is on its way', () async {
      await cubit.load();

      await cubit.requestOtp();

      expect(repository.otpCalls, 0);
    });

    test('otp_not_available reads as unavailable', () async {
      details = _parcel(status: C2cParcelStatus.outForDelivery);
      await cubit.load();
      repository.onOtp = () async =>
          const Left(ServerFailure(code: C2cParcelErrorCode.otpNotAvailable));

      await cubit.requestOtp();

      expect(loaded().otp, const OtpUnavailable());
    });

    test('a delivered parcel drops the shown code', () async {
      details = _parcel(status: C2cParcelStatus.outForDelivery, version: 8);
      await cubit.load();
      repository.onOtp = () async => const Right(
        C2cParcelOtp(code: '482913', purpose: C2cOtpPurpose.delivery),
      );
      await cubit.requestOtp();

      details = _parcel(status: C2cParcelStatus.delivered, version: 9);
      await cubit.refresh();

      expect(loaded().otp, const OtpIdle());
    });

    test('a delivery code is dropped once the parcel turns back', () async {
      details = _parcel(status: C2cParcelStatus.outForDelivery, version: 8);
      await cubit.load();
      repository.onOtp = () async => const Right(
        C2cParcelOtp(code: '482913', purpose: C2cOtpPurpose.delivery),
      );
      await cubit.requestOtp();

      details = _parcel(status: C2cParcelStatus.returningToSender, version: 9);
      await cubit.refresh();

      expect(loaded().otp, const OtpIdle());
    });

    test('a code answered after the stage changed is not shown', () async {
      details = _parcel(status: C2cParcelStatus.outForDelivery, version: 8);
      await cubit.load();
      final Completer<Either<Failure, C2cParcelOtp>> answer =
          Completer<Either<Failure, C2cParcelOtp>>();
      repository.onOtp = () => answer.future;
      final Future<void> asked = cubit.requestOtp();

      details = _parcel(status: C2cParcelStatus.returningToSender, version: 9);
      await cubit.refresh();
      answer.complete(
        const Right(
          C2cParcelOtp(code: '482913', purpose: C2cOtpPurpose.delivery),
        ),
      );
      await asked;

      expect(loaded().otp, const OtpIdle());
    });
  });
}
