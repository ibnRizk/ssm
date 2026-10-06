import 'dart:async';

import 'package:dartz/dartz.dart';
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

const DeliveryOtp _code = DeliveryOtp(code: '042913');

const GeoPoint _here = GeoPoint(latitude: 24.705, longitude: 46.69);

/// Answers through [Completer]s the test controls, so ordering is explicit
/// rather than timing-dependent.
class _FakeParcelsRepository implements ParcelsRepository {
  Completer<Either<Failure, List<Parcel>>> list =
      Completer<Either<Failure, List<Parcel>>>();
  Completer<Either<Failure, Unit>> send = Completer<Either<Failure, Unit>>();
  Completer<Either<Failure, DeliveryOtp>> otp =
      Completer<Either<Failure, DeliveryOtp>>();
  int listCalls = 0;
  final List<(int, ParcelDropoff)> sent = <(int, ParcelDropoff)>[];
  final List<int> otpRequests = <int>[];

  @override
  Future<Either<Failure, List<Parcel>>> getParcels() {
    listCalls++;
    return list.future;
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
}
