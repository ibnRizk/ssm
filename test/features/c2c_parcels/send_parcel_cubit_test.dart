import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/core/location/geo_point.dart';
import 'package:ssm/core/location/location_repository.dart';
import 'package:ssm/features/c2c_parcels/domain/entities/c2c_parcel_quote.dart';
import 'package:ssm/features/c2c_parcels/presentation/cubit/send_parcel_cubit.dart';
import 'package:ssm/features/c2c_parcels/presentation/cubit/send_parcel_state.dart';

import 'fake_c2c_parcels_repository.dart';

const GeoPoint _home = GeoPoint(latitude: 24.7136, longitude: 46.6753);
const GeoPoint _office = GeoPoint(latitude: 24.75, longitude: 46.7);

const C2cParcelQuote _discounted = C2cParcelQuote(
  baseTotalFee: 50,
  subscriptionDiscount: 50,
  totalFee: 0,
  currency: 'SAR',
  appliedSubscription: AppliedParcelSubscription(remainingDeliveries: 29),
);

const C2cParcelQuote _plain = C2cParcelQuote(
  baseTotalFee: 25,
  subscriptionDiscount: 0,
  totalFee: 25,
  currency: 'SAR',
);

/// Every quote answers through a [Completer] the test controls, so the
/// stale-answer race is explicit rather than timing-dependent.
class _FakeRepository extends FakeC2cParcelsRepository {
  final List<Completer<Either<Failure, C2cParcelQuote>>> pending =
      <Completer<Either<Failure, C2cParcelQuote>>>[];

  _FakeRepository() {
    onQuote = (_) {
      final Completer<Either<Failure, C2cParcelQuote>> completer =
          Completer<Either<Failure, C2cParcelQuote>>();
      pending.add(completer);
      return completer.future;
    };
  }

  List<C2cQuoteRequest> get requests => quotes;
}

class _FakeLocationRepository implements LocationRepository {
  Completer<Either<Failure, GeoPoint>> pending =
      Completer<Either<Failure, GeoPoint>>();

  @override
  Future<Either<Failure, GeoPoint>> getCurrentLocation() => pending.future;
}

void main() {
  late _FakeRepository repository;
  late _FakeLocationRepository location;
  late SendParcelCubit cubit;

  setUp(() {
    repository = _FakeRepository();
    location = _FakeLocationRepository();
    cubit = SendParcelCubit(
      repository: repository,
      locationRepository: location,
    );
  });

  tearDown(() => cubit.close());

  void setBothEnds() {
    cubit
      ..setPoint(ParcelEnd.pickup, _home)
      ..setPoint(ParcelEnd.dropoff, _office);
  }

  group('requestQuote', () {
    test('does nothing until both ends are set', () async {
      cubit.setPoint(ParcelEnd.pickup, _home);

      await cubit.requestQuote(weightKg: 3);

      expect(repository.requests, isEmpty);
      expect(cubit.state.quote, const QuoteIdle());
    });

    test('sends the inputs and shows the quote', () async {
      setBothEnds();
      cubit
        ..setCategory(ParcelCategory.large)
        ..setFragile(true);

      final Future<void> request = cubit.requestQuote(
        weightKg: 3,
        title: '  Gift Box ',
      );
      expect(cubit.state.quote, const QuoteLoading());
      repository.pending.single.complete(const Right(_discounted));
      await request;

      const C2cQuoteRequest expected = C2cQuoteRequest(
        sender: _home,
        recipient: _office,
        category: ParcelCategory.large,
        weightKg: 3,
        isFragile: true,
        title: 'Gift Box',
      );
      expect(repository.requests.single, expected);
      // The priced request travels with its price, for the create step.
      expect(cubit.state.quote, const QuoteReady(_discounted, expected));
    });

    test('a blank title is sent as none', () async {
      setBothEnds();

      final Future<void> request = cubit.requestQuote(weightKg: 1, title: ' ');
      repository.pending.single.complete(const Right(_plain));
      await request;

      expect(repository.requests.single.title, isNull);
    });

    test('reports a refused quote', () async {
      setBothEnds();

      final Future<void> request = cubit.requestQuote(weightKg: 90);
      repository.pending.single.complete(
        const Left(ForbiddenFailure(message: 'Too heavy')),
      );
      await request;

      expect(
        cubit.state.quote,
        const QuoteFailed(ForbiddenFailure(message: 'Too heavy')),
      );
    });

    test('ignores a second request while one is on its way', () async {
      setBothEnds();

      final Future<void> first = cubit.requestQuote(weightKg: 3);
      await cubit.requestQuote(weightKg: 3);
      repository.pending.single.complete(const Right(_plain));
      await first;

      expect(repository.requests, hasLength(1));
    });

    test('drops an answer for inputs that changed meanwhile', () async {
      setBothEnds();

      final Future<void> request = cubit.requestQuote(weightKg: 3);
      cubit.setCategory(ParcelCategory.small);
      repository.pending.single.complete(const Right(_discounted));
      await request;

      expect(cubit.state.quote, const QuoteIdle());
    });
  });

  group('input changes', () {
    Future<void> quoted() async {
      setBothEnds();
      final Future<void> request = cubit.requestQuote(weightKg: 3);
      repository.pending.single.complete(const Right(_plain));
      await request;
    }

    test('moving an end clears the quote', () async {
      await quoted();

      cubit.setPoint(ParcelEnd.dropoff, _home);

      expect(cubit.state.quote, const QuoteIdle());
      expect(cubit.state.dropoff, _home);
    });

    test('a changed weight or title clears the quote', () async {
      await quoted();

      cubit.inputsChanged();

      expect(cubit.state.quote, const QuoteIdle());
    });

    test('re-selecting the same category keeps the quote', () async {
      await quoted();

      cubit.setCategory(ParcelCategory.medium);

      expect(cubit.state.quote, isA<QuoteReady>());
    });
  });

  group('useCurrentLocation', () {
    test('sets the end to the device position', () async {
      final Future<void> locate = cubit.useCurrentLocation(ParcelEnd.pickup);
      expect(cubit.state.locating, ParcelEnd.pickup);

      location.pending.complete(const Right(_home));
      await locate;

      expect(cubit.state.pickup, _home);
      expect(cubit.state.locating, isNull);
    });

    test('reports a location failure once', () async {
      const LocationFailure failure = LocationFailure(
        reason: LocationFailureReason.permissionDenied,
      );

      final Future<void> locate = cubit.useCurrentLocation(ParcelEnd.pickup);
      location.pending.complete(const Left(failure));
      await locate;

      expect(cubit.state.notice, failure);
      expect(cubit.state.pickup, isNull);

      cubit.setCategory(ParcelCategory.small);
      expect(cubit.state.notice, isNull);
    });

    test('one end at a time', () async {
      final Future<void> locate = cubit.useCurrentLocation(ParcelEnd.pickup);
      await cubit.useCurrentLocation(ParcelEnd.dropoff);

      location.pending.complete(const Right(_home));
      await locate;

      expect(cubit.state.pickup, _home);
      expect(cubit.state.dropoff, isNull);
    });
  });
}
