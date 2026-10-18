import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:fake_async/fake_async.dart';
import 'package:ssm/core/delivery_otp/delivery_otp.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/core/location/geo_point.dart';
import 'package:ssm/core/location/location_repository.dart';
import 'package:ssm/features/parcels/domain/entities/parcel.dart';
import 'package:ssm/features/parcels/domain/repos/parcels_repository.dart';
import 'package:ssm/features/parcels/presentation/cubit/parcels_cubit.dart';
import 'package:ssm/features/parcels/presentation/cubit/parcels_state.dart';
import 'package:flutter_test/flutter_test.dart';

const Parcel _atWarehouse = Parcel(
  id: 2048,
  reference: 'SSM-P2048',
  status: ParcelStatus.atWarehouse,
  paymentType: ParcelPaymentType.cod,
  codAmount: 45,
  deliveryFee: 0,
  currency: 'SAR',
);

const Parcel _outForDelivery = Parcel(
  id: 3001,
  reference: 'SSM-P3001',
  status: ParcelStatus.outForDelivery,
  paymentType: ParcelPaymentType.prepaid,
  codAmount: 0,
  deliveryFee: 0,
  currency: 'SAR',
);

const Parcel _delivered = Parcel(
  id: 3001,
  reference: 'SSM-P3001',
  status: ParcelStatus.delivered,
  paymentType: ParcelPaymentType.prepaid,
  codAmount: 0,
  deliveryFee: 0,
  currency: 'SAR',
);

const DeliveryOtp _code = DeliveryOtp(code: '042913');

const GeoPoint _here = GeoPoint(latitude: 24.705, longitude: 46.69);

/// Answers through [Completer]s the test controls, so ordering is explicit
/// rather than timing-dependent.
class _FakeParcelsRepository implements ParcelsRepository {
  Completer<Either<Failure, List<Parcel>>> list =
      Completer<Either<Failure, List<Parcel>>>();
  Completer<Either<Failure, Parcel>> one = Completer<Either<Failure, Parcel>>();
  Completer<Either<Failure, Unit>> send = Completer<Either<Failure, Unit>>();
  Completer<Either<Failure, DeliveryOtp>> otp =
      Completer<Either<Failure, DeliveryOtp>>();
  int listCalls = 0;
  final List<int> detailRequests = <int>[];
  final List<(int, ParcelDropoff)> sent = <(int, ParcelDropoff)>[];
  final List<int> otpRequests = <int>[];

  @override
  Future<Either<Failure, List<Parcel>>> getParcels() {
    listCalls++;
    return list.future;
  }

  @override
  Future<Either<Failure, Parcel>> getParcel(int parcelId) {
    detailRequests.add(parcelId);
    return one.future;
  }

  @override
  Future<Either<Failure, Unit>> sendDropoff(
    int parcelId,
    ParcelDropoff dropoff,
  ) {
    sent.add((parcelId, dropoff));
    return send.future;
  }

  @override
  Future<Either<Failure, DeliveryOtp>> requestDeliveryOtp(int parcelId) {
    otpRequests.add(parcelId);
    return otp.future;
  }
}

class _FakeLocationRepository implements LocationRepository {
  Completer<Either<Failure, GeoPoint>> pending =
      Completer<Either<Failure, GeoPoint>>();

  @override
  Future<Either<Failure, GeoPoint>> getCurrentLocation() => pending.future;
}

/// Synchronously-answering fake for polling unit tests. Uses [Future.value]
/// so each fetch completes within the same [FakeAsync.flushMicrotasks] call.
/// Set [nextCompleter] to make one fetch block until explicitly completed.
class _SyncParcelsRepo implements ParcelsRepository {
  Either<Failure, List<Parcel>> listResult;
  int listCalls = 0;

  /// If non-null the next [getParcels] call returns this completer's future
  /// (allowing in-flight tests), then clears itself.
  Completer<Either<Failure, List<Parcel>>>? nextCompleter;

  _SyncParcelsRepo({required this.listResult});

  @override
  Future<Either<Failure, List<Parcel>>> getParcels() {
    listCalls++;
    if (nextCompleter case final Completer<Either<Failure, List<Parcel>>> c) {
      nextCompleter = null;
      return c.future;
    }
    return Future<Either<Failure, List<Parcel>>>.value(listResult);
  }

  @override
  Future<Either<Failure, Parcel>> getParcel(int parcelId) =>
      Future<Either<Failure, Parcel>>.value(
        const Left<Failure, Parcel>(NotFoundFailure()),
      );

  @override
  Future<Either<Failure, Unit>> sendDropoff(
    int parcelId,
    ParcelDropoff dropoff,
  ) => Future<Either<Failure, Unit>>.value(const Right<Failure, Unit>(unit));

  @override
  Future<Either<Failure, DeliveryOtp>> requestDeliveryOtp(int parcelId) =>
      Future<Either<Failure, DeliveryOtp>>.value(
        const Left<Failure, DeliveryOtp>(ConflictFailure()),
      );
}

void main() {
  late _FakeParcelsRepository parcels;
  late _FakeLocationRepository location;
  late ParcelsCubit cubit;

  setUp(() {
    parcels = _FakeParcelsRepository();
    location = _FakeLocationRepository();
    cubit = ParcelsCubit(
      parcelsRepository: parcels,
      locationRepository: location,
    );
  });

  tearDown(() => cubit.close());

  ParcelsLoaded loaded() => cubit.state as ParcelsLoaded;

  Future<void> loadWith(List<Parcel> list) async {
    final Future<void> fetch = cubit.fetchParcels();
    parcels.list.complete(Right<Failure, List<Parcel>>(list));
    await fetch;
    parcels.list = Completer<Either<Failure, List<Parcel>>>();
  }

  Future<void> send() => cubit.sendDropoffLocation(
    _atWarehouse.id,
    deliveryAddress: '  Al Malaz, gate 2 ',
    notes: ' Call on arrival ',
  );

  group('fetchParcels', () {
    test('emits loading then the list', () async {
      final Future<void> expectation = expectLater(
        cubit.stream,
        emitsInOrder(<ParcelsState>[
          const ParcelsLoading(),
          const ParcelsLoaded(parcels: <Parcel>[_atWarehouse]),
        ]),
      );

      await loadWith(<Parcel>[_atWarehouse]);
      await expectation;
    });

    test('emits the failure on a first load', () async {
      final Future<void> fetch = cubit.fetchParcels();
      parcels.list.complete(const Left(NetworkFailure()));
      await fetch;

      expect(cubit.state, const ParcelsError(NetworkFailure()));
    });

    test('a manual refresh keeps the list and flags progress', () async {
      await loadWith(<Parcel>[_atWarehouse]);

      unawaited(cubit.fetchParcels());

      expect(loaded().isRefreshing, isTrue);
      expect(loaded().parcels, <Parcel>[_atWarehouse]);
      parcels.list.complete(const Right(<Parcel>[]));
    });

    test('a failed refresh keeps the list and reports once', () async {
      await loadWith(<Parcel>[_atWarehouse]);

      final Future<void> refresh = cubit.fetchParcels();
      parcels.list.complete(const Left(ServerFailure()));
      await refresh;

      expect(
        loaded(),
        const ParcelsLoaded(
          parcels: <Parcel>[_atWarehouse],
          refreshFailure: ServerFailure(),
        ),
      );
    });
  });

  group('refreshParcel', () {
    Future<void> refreshWith(int id, Either<Failure, Parcel> answer) async {
      final Future<void> refresh = cubit.refreshParcel(id);
      parcels.one.complete(answer);
      await refresh;
      parcels.one = Completer<Either<Failure, Parcel>>();
    }

    const Parcel nowOut = Parcel(
      id: 2048,
      reference: 'SSM-P2048',
      status: ParcelStatus.outForDelivery,
      paymentType: ParcelPaymentType.cod,
      codAmount: 45,
      deliveryFee: 0,
      currency: 'SAR',
    );

    test('swaps the fresh parcel into the list in place', () async {
      await loadWith(<Parcel>[_outForDelivery, _atWarehouse]);

      await refreshWith(2048, const Right<Failure, Parcel>(nowOut));

      expect(parcels.detailRequests, <int>[2048]);
      expect(loaded().parcels, <Parcel>[_outForDelivery, nowOut]);
    });

    test('appends a parcel that is not on the first page', () async {
      await loadWith(<Parcel>[_atWarehouse]);

      await refreshWith(3001, const Right<Failure, Parcel>(_outForDelivery));

      expect(loaded().parcels, <Parcel>[_atWarehouse, _outForDelivery]);
    });

    test('a failure keeps the list and reports it once', () async {
      await loadWith(<Parcel>[_atWarehouse]);

      await refreshWith(2048, const Left<Failure, Parcel>(NotFoundFailure()));

      expect(
        loaded(),
        const ParcelsLoaded(
          parcels: <Parcel>[_atWarehouse],
          refreshFailure: NotFoundFailure(),
        ),
      );
    });

    test('asked before the list loads, runs once it has', () async {
      final Future<void> fetch = cubit.fetchParcels();
      await cubit.refreshParcel(2048);
      expect(parcels.detailRequests, isEmpty);

      parcels.list.complete(const Right(<Parcel>[_atWarehouse]));
      await pumpEventQueue();
      expect(parcels.detailRequests, <int>[2048]);

      parcels.one.complete(const Right<Failure, Parcel>(nowOut));
      await fetch;
      expect(loaded().parcels, <Parcel>[nowOut]);
    });

    test('fetches the code of a parcel that just went out', () async {
      await loadWith(<Parcel>[_atWarehouse]);

      await refreshWith(2048, const Right<Failure, Parcel>(nowOut));

      expect(parcels.otpRequests, <int>[2048]);
    });

    // Regression: the details screen had its own cubit, whose first fetch
    // requested a new code — invalidating the one the list was showing.
    test('opening details keeps a code already shown', () async {
      await loadWith(<Parcel>[_outForDelivery]);
      parcels.otp.complete(const Right<Failure, DeliveryOtp>(_code));
      await pumpEventQueue();

      await refreshWith(3001, const Right<Failure, Parcel>(_outForDelivery));

      expect(parcels.otpRequests, <int>[3001]);
      expect(loaded().otps[3001], const OtpReady(_code));
    });
  });

  group('sendDropoffLocation', () {
    test('locates, then sends the trimmed details with the fix', () async {
      await loadWith(<Parcel>[_atWarehouse]);

      final Future<void> pending = send();
      expect(
        loaded().dropoff,
        const DropoffInProgress(2048, DropoffStage.locating),
      );

      location.pending.complete(const Right<Failure, GeoPoint>(_here));
      await Future<void>.delayed(Duration.zero);
      expect(
        loaded().dropoff,
        const DropoffInProgress(2048, DropoffStage.sending),
      );

      parcels.send.complete(const Right<Failure, Unit>(unit));
      await Future<void>.delayed(Duration.zero);
      parcels.list.complete(const Right(<Parcel>[_atWarehouse]));
      await pending;

      expect(parcels.sent.single, (
        2048,
        const ParcelDropoff(
          location: _here,
          deliveryAddress: 'Al Malaz, gate 2',
          notes: 'Call on arrival',
        ),
      ));
      expect(loaded().dropoff, const DropoffSent(2048));
    });

    test('refetches the list after a successful send', () async {
      await loadWith(<Parcel>[_atWarehouse]);

      final Future<void> pending = send();
      location.pending.complete(const Right<Failure, GeoPoint>(_here));
      await Future<void>.delayed(Duration.zero);
      parcels.send.complete(const Right<Failure, Unit>(unit));
      await Future<void>.delayed(Duration.zero);
      parcels.list.complete(const Right(<Parcel>[]));
      await pending;

      expect(parcels.listCalls, 2);
      expect(loaded().parcels, isEmpty);
    });

    test('a location failure never reaches the API', () async {
      await loadWith(<Parcel>[_atWarehouse]);

      final Future<void> pending = send();
      location.pending.complete(
        const Left(
          LocationFailure(reason: LocationFailureReason.permissionDenied),
        ),
      );
      await pending;

      expect(parcels.sent, isEmpty);
      expect(
        loaded().dropoff,
        const DropoffFailed(
          2048,
          LocationFailure(reason: LocationFailureReason.permissionDenied),
        ),
      );
    });

    test('reports the API refusal (422) without refetching', () async {
      await loadWith(<Parcel>[_atWarehouse]);

      final Future<void> pending = send();
      location.pending.complete(const Right<Failure, GeoPoint>(_here));
      await Future<void>.delayed(Duration.zero);
      parcels.send.complete(
        const Left<Failure, Unit>(ServerFailure(message: 'Already delivered')),
      );
      await pending;

      expect(
        loaded().dropoff,
        const DropoffFailed(2048, ServerFailure(message: 'Already delivered')),
      );
      expect(parcels.listCalls, 1);
    });

    test('a refresh already running when the send lands is followed by '
        'an owed reload', () async {
      await loadWith(<Parcel>[_atWarehouse]);

      // Send starts; while locating, the customer taps "Update now".
      final Future<void> pending = send();
      final Future<void> refresh = cubit.fetchParcels();
      final Completer<Either<Failure, List<Parcel>>> staleAnswer = parcels.list;
      parcels.list = Completer<Either<Failure, List<Parcel>>>();

      // The send is accepted while that refresh is still out.
      location.pending.complete(const Right<Failure, GeoPoint>(_here));
      await Future<void>.delayed(Duration.zero);
      parcels.send.complete(const Right<Failure, Unit>(unit));
      await pending;
      expect(parcels.listCalls, 2, reason: 'no second fetch while one runs');

      // The refresh answers with the pre-send list; the owed reload follows.
      staleAnswer.complete(const Right(<Parcel>[_atWarehouse]));
      await Future<void>.delayed(Duration.zero);
      expect(parcels.listCalls, 3);

      const Parcel withDropoff = Parcel(
        id: 2048,
        reference: 'SSM-P2048',
        status: ParcelStatus.atWarehouse,
        paymentType: ParcelPaymentType.cod,
        codAmount: 45,
        deliveryFee: 0,
        currency: 'SAR',
        dropoffLocation: _here,
      );
      parcels.list.complete(const Right(<Parcel>[withDropoff]));
      await refresh;

      expect(loaded().parcels, <Parcel>[withDropoff]);
      expect(loaded().isRefreshing, isFalse);
    });

    test('a manual refresh alone is not repeated', () async {
      await loadWith(<Parcel>[_atWarehouse]);

      final Future<void> refresh = cubit.fetchParcels();
      await cubit.fetchParcels();
      parcels.list.complete(const Right(<Parcel>[_atWarehouse]));
      await refresh;

      expect(parcels.listCalls, 2);
    });

    test('can be retried after a failure', () async {
      await loadWith(<Parcel>[_atWarehouse]);
      final Future<void> first = send();
      location.pending.complete(const Left(NetworkFailure()));
      await first;
      expect(loaded().dropoff, isA<DropoffFailed>());

      location.pending = Completer<Either<Failure, GeoPoint>>();
      final Future<void> retry = send();
      location.pending.complete(const Right<Failure, GeoPoint>(_here));
      await Future<void>.delayed(Duration.zero);
      parcels.send.complete(const Right<Failure, Unit>(unit));
      await Future<void>.delayed(Duration.zero);
      parcels.list.complete(const Right(<Parcel>[_atWarehouse]));
      await retry;

      expect(parcels.sent, hasLength(1));
      expect(loaded().dropoff, const DropoffSent(2048));
    });

    test('ignores a second send while one is in flight', () async {
      await loadWith(<Parcel>[_atWarehouse]);

      unawaited(send());
      await send();

      expect(
        loaded().dropoff,
        const DropoffInProgress(2048, DropoffStage.locating),
      );
      location.pending.complete(const Left(NetworkFailure()));
    });

    test('does nothing before the list has loaded', () async {
      await send();

      expect(cubit.state, const ParcelsInitial());
    });
  });

  group('delivery OTP', () {
    Future<void> answerOtp(Either<Failure, DeliveryOtp> answer) async {
      parcels.otp.complete(answer);
      await pumpEventQueue();
      parcels.otp = Completer<Either<Failure, DeliveryOtp>>();
    }

    test('is fetched once a parcel is out for delivery', () async {
      await loadWith(<Parcel>[_outForDelivery]);

      expect(parcels.otpRequests, <int>[3001]);
    });

    test('is not fetched for a parcel still at the warehouse', () async {
      await loadWith(<Parcel>[_atWarehouse]);

      expect(parcels.otpRequests, isEmpty);
    });

    test('shows the code once it arrives', () async {
      await loadWith(<Parcel>[_outForDelivery]);

      await answerOtp(const Right<Failure, DeliveryOtp>(_code));

      expect(loaded().otps, <int, DeliveryOtpState>{
        3001: const OtpReady(_code),
      });
    });

    test('a 409 reads as not available yet', () async {
      await loadWith(<Parcel>[_outForDelivery]);

      await answerOtp(const Left<Failure, DeliveryOtp>(ConflictFailure()));

      expect(loaded().otps[3001], const OtpUnavailable());
    });

    test('a network failure is shown with a retry', () async {
      await loadWith(<Parcel>[_outForDelivery]);

      await answerOtp(const Left<Failure, DeliveryOtp>(NetworkFailure()));

      expect(loaded().otps[3001], const OtpFailed(NetworkFailure()));
    });

    test('a refresh keeps the code instead of requesting another', () async {
      await loadWith(<Parcel>[_outForDelivery]);
      await answerOtp(const Right<Failure, DeliveryOtp>(_code));

      await loadWith(<Parcel>[_outForDelivery]);

      expect(parcels.otpRequests, <int>[3001]);
      expect(loaded().otps[3001], const OtpReady(_code));
    });

    test('the customer can ask for a new code', () async {
      await loadWith(<Parcel>[_outForDelivery]);
      await answerOtp(const Right<Failure, DeliveryOtp>(_code));

      unawaited(cubit.requestDeliveryOtp(3001));

      expect(parcels.otpRequests, <int>[3001, 3001]);
      expect(loaded().otps[3001], const OtpLoading());
    });

    test('a second request while one is on its way is ignored', () async {
      await loadWith(<Parcel>[_outForDelivery]);

      await cubit.requestDeliveryOtp(3001);

      expect(parcels.otpRequests, <int>[3001]);
    });

    test('is dropped once the parcel is delivered', () async {
      await loadWith(<Parcel>[_outForDelivery]);
      await answerOtp(const Right<Failure, DeliveryOtp>(_code));
      const Parcel delivered = Parcel(
        id: 3001,
        reference: 'SSM-P3001',
        status: ParcelStatus.delivered,
        paymentType: ParcelPaymentType.prepaid,
        codAmount: 0,
        deliveryFee: 0,
        currency: 'SAR',
      );

      await loadWith(<Parcel>[delivered]);

      expect(loaded().otps, isEmpty);
    });

    test('is never requested for a parcel not out for delivery', () async {
      await loadWith(<Parcel>[_atWarehouse]);

      await cubit.requestDeliveryOtp(_atWarehouse.id);

      expect(parcels.otpRequests, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // Polling — uses fakeAsync so timers run without real waiting.
  //
  // A separate sync-answering fake repository is used here so that each
  // timer tick's fetch completes inside the same elapse() call.
  // ---------------------------------------------------------------------------

  group('startPolling / stopPolling', () {
    late _SyncParcelsRepo syncParcels;
    late ParcelsCubit pollCubit;

    setUp(() {
      syncParcels = _SyncParcelsRepo(
        listResult: const Right<Failure, List<Parcel>>(<Parcel>[_outForDelivery]),
      );
      pollCubit = ParcelsCubit(
        parcelsRepository: syncParcels,
        locationRepository: location,
      );
    });

    tearDown(() => pollCubit.close());

    // Loads the cubit synchronously inside a fakeAsync block.
    void loadSync(FakeAsync async) {
      pollCubit.fetchParcels();
      async.flushMicrotasks();
    }

    test('polls every 30 s while active parcels exist', () {
      fakeAsync((FakeAsync async) {
        loadSync(async);
        pollCubit.startPolling();

        async.elapse(const Duration(seconds: 30));
        expect(syncParcels.listCalls, 2);

        async.elapse(const Duration(seconds: 30));
        expect(syncParcels.listCalls, 3);
      });
    });

    test('does not poll when every parcel is delivered', () {
      fakeAsync((FakeAsync async) {
        syncParcels.listResult = const Right<Failure, List<Parcel>>(
          <Parcel>[_delivered],
        );
        loadSync(async);
        pollCubit.startPolling();

        async.elapse(const Duration(seconds: 30));
        expect(syncParcels.listCalls, 1); // only initial load
      });
    });

    test('does not poll when state is ParcelsError (first-load failed)', () {
      // Current behaviour: after ParcelsError the timer still runs but
      // _hasActiveParcels is false (state is not ParcelsLoaded), so no
      // background fetch is attempted. This is intentional: the user sees
      // an error screen with an explicit "Retry" button, and auto-polling
      // while an error is displayed would feel erratic. The customer should
      // control retries.
      fakeAsync((FakeAsync async) {
        syncParcels.listResult = const Left<Failure, List<Parcel>>(
          NetworkFailure(),
        );
        loadSync(async);
        expect(pollCubit.state, isA<ParcelsError>());

        pollCubit.startPolling();

        async.elapse(const Duration(seconds: 30));
        expect(syncParcels.listCalls, 1); // no auto-retry
      });
    });

    test('stopPolling stops the timer', () {
      fakeAsync((FakeAsync async) {
        loadSync(async);
        pollCubit.startPolling();
        pollCubit.stopPolling();

        async.elapse(const Duration(seconds: 30));
        expect(syncParcels.listCalls, 1); // only initial load
      });
    });

    test('calling startPolling twice does not create two timers', () {
      fakeAsync((FakeAsync async) {
        loadSync(async);
        pollCubit.startPolling();
        pollCubit.startPolling();

        async.elapse(const Duration(seconds: 30));
        // Exactly one tick: the second startPolling cancelled the first timer.
        expect(syncParcels.listCalls, 2);
      });
    });

    // Calling close() inside fakeAsync creates an orphaned Future (the bloc's
    // StreamController close is async and can't be fully drained by the fake
    // scheduler). Use a dedicated cubit and regular async for this test so the
    // Future completes cleanly in the real event loop.
    test('close cancels the timer — no fetch fires after close', () async {
      final _SyncParcelsRepo closeRepo = _SyncParcelsRepo(
        listResult: const Right<Failure, List<Parcel>>(<Parcel>[_outForDelivery]),
      );
      final ParcelsCubit closable = ParcelsCubit(
        parcelsRepository: closeRepo,
        locationRepository: location,
      );

      // Load with an active parcel so the timer would poll if not cancelled.
      unawaited(closable.fetchParcels());
      await pumpEventQueue();
      expect(closeRepo.listCalls, 1);

      closable.startPolling();

      // close() synchronously cancels _pollTimer before calling super.close().
      await closable.close();

      // The 30-second timer hasn't fired (we closed immediately).
      // No extra fetch was made.
      expect(closeRepo.listCalls, 1);
      expect(closable.isClosed, isTrue);
    });

    test('a poll tick while a fetch is in flight does not stack a second request', () {
      fakeAsync((FakeAsync async) {
        // Slow first load: controlled by a completer.
        final Completer<Either<Failure, List<Parcel>>> slowFetch =
            Completer<Either<Failure, List<Parcel>>>();
        syncParcels.nextCompleter = slowFetch;

        pollCubit.fetchParcels(); // starts the slow initial load
        pollCubit.startPolling();

        // Timer fires at 30 s — fetch is still in flight, guard skips it.
        async.elapse(const Duration(seconds: 30));
        expect(syncParcels.listCalls, 1);

        // Complete the first fetch; timer fires again at 60 s.
        slowFetch.complete(
          const Right<Failure, List<Parcel>>(<Parcel>[_outForDelivery]),
        );
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 30));
        expect(syncParcels.listCalls, 2);
      });
    });

    test('a failed poll keeps the list and sets no refreshFailure (silent)', () {
      fakeAsync((FakeAsync async) {
        loadSync(async);
        final ParcelsLoaded before = pollCubit.state as ParcelsLoaded;

        syncParcels.listResult = const Left<Failure, List<Parcel>>(
          NetworkFailure(),
        );
        pollCubit.startPolling();
        async.elapse(const Duration(seconds: 30));

        final ParcelsLoaded after = pollCubit.state as ParcelsLoaded;
        expect(after.parcels, before.parcels, reason: 'list preserved');
        expect(after.refreshFailure, isNull, reason: 'background poll is silent');
      });
    });

    test('the next tick retries and recovers after a failed poll', () {
      fakeAsync((FakeAsync async) {
        loadSync(async);

        // First poll fails.
        syncParcels.listResult = const Left<Failure, List<Parcel>>(
          NetworkFailure(),
        );
        pollCubit.startPolling();
        async.elapse(const Duration(seconds: 30));
        expect(pollCubit.state, isA<ParcelsLoaded>());

        // Second poll succeeds with new data.
        const Parcel updated = Parcel(
          id: 3001,
          reference: 'SSM-P3001',
          status: ParcelStatus.outForDelivery,
          paymentType: ParcelPaymentType.prepaid,
          codAmount: 0,
          deliveryFee: 15,
          currency: 'SAR',
        );
        syncParcels.listResult = const Right<Failure, List<Parcel>>(
          <Parcel>[updated],
        );
        async.elapse(const Duration(seconds: 30));

        expect(
          (pollCubit.state as ParcelsLoaded).parcels,
          <Parcel>[updated],
        );
        expect(
          (pollCubit.state as ParcelsLoaded).refreshFailure,
          isNull,
        );
      });
    });

    test('no infinite error loop — exactly one fetch per 30 s tick', () {
      fakeAsync((FakeAsync async) {
        loadSync(async);

        syncParcels.listResult = const Left<Failure, List<Parcel>>(
          NetworkFailure(),
        );
        pollCubit.startPolling();

        // Advance 5 minutes = 10 timer ticks.
        async.elapse(const Duration(minutes: 5));

        // 1 initial load + 10 poll ticks = 11 calls.
        expect(syncParcels.listCalls, 11);
      });
    });
  });
}
