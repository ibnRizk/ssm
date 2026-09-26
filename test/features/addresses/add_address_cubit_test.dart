import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/features/addresses/domain/entities/address.dart';
import 'package:ssm/features/addresses/domain/repos/address_repository.dart';
import 'package:ssm/core/location/location_repository.dart';
import 'package:ssm/features/addresses/presentation/cubit/add_address_cubit.dart';
import 'package:ssm/features/addresses/presentation/cubit/add_address_state.dart';
import 'package:ssm/features/addresses/presentation/utils/address_messages.dart';
import 'package:flutter_test/flutter_test.dart';

const GeoPoint _riyadh = GeoPoint(latitude: 24.71, longitude: 46.68);

class _FakeAddressRepository implements AddressRepository {
  Completer<Either<Failure, Unit>> add = Completer<Either<Failure, Unit>>();
  final List<NewAddress> added = <NewAddress>[];

  @override
  Future<Either<Failure, List<Address>>> getAddresses() =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> addAddress(NewAddress address) {
    added.add(address);
    return add.future;
  }

  @override
  Future<Either<Failure, Unit>> deleteAddress(int id) =>
      throw UnimplementedError();
}

class _FakeLocationRepository implements LocationRepository {
  Completer<Either<Failure, GeoPoint>> pending =
      Completer<Either<Failure, GeoPoint>>();
  int calls = 0;

  @override
  Future<Either<Failure, GeoPoint>> getCurrentLocation() {
    calls++;
    return pending.future;
  }
}

void main() {
  late _FakeAddressRepository addresses;
  late _FakeLocationRepository location;
  late AddAddressCubit cubit;

  setUp(() {
    addresses = _FakeAddressRepository();
    location = _FakeLocationRepository();
    cubit = AddAddressCubit(
      addressRepository: addresses,
      locationRepository: location,
    );
  });

  tearDown(() => cubit.close());

  Future<void> locateAt(GeoPoint point) async {
    final Future<void> locate = cubit.locate();
    location.pending.complete(Right<Failure, GeoPoint>(point));
    await locate;
    location.pending = Completer<Either<Failure, GeoPoint>>();
  }

  Future<void> submit() => cubit.submit(
    type: AddressType.office,
    contactPersonName: '  Sara   Customer ',
    contactPersonNumber: '0512345678',
    address: '  Olaya St 12  ',
  );

  group('locate', () {
    test('stores the device location', () async {
      await locateAt(_riyadh);

      expect(
        cubit.state,
        const AddAddressState(
          location: _riyadh,
          locationSource: LocationSource.device,
        ),
      );
    });

    test('reports why the location is unavailable', () async {
      final Future<void> locate = cubit.locate();
      location.pending.complete(
        const Left(
          LocationFailure(reason: LocationFailureReason.serviceDisabled),
        ),
      );
      await locate;

      expect(
        cubit.state,
        const AddAddressState(
          failure: LocationFailure(
            reason: LocationFailureReason.serviceDisabled,
          ),
        ),
      );
    });

    test('ignores a second locate while one is in flight', () async {
      final Future<void> first = cubit.locate();
      await cubit.locate();
      location.pending.complete(const Right<Failure, GeoPoint>(_riyadh));
      await first;

      expect(location.calls, 1);
    });
  });

  group('pickLocation', () {
    const GeoPoint pinned = GeoPoint(latitude: 21.2146, longitude: 41.633);

    test('stores a pin placed on the map', () {
      cubit.pickLocation(pinned);

      expect(cubit.state, const AddAddressState(location: pinned));
    });

    test('clears an out-of-coverage error so the customer can retry', () async {
      await locateAt(_riyadh);
      final Future<void> pending = submit();
      addresses.add.complete(
        const Left<Failure, Unit>(ForbiddenFailure(code: outOfCoverageCode)),
      );
      await pending;

      cubit.pickLocation(pinned);

      expect(cubit.state.failure, isNull);
      expect(cubit.state.location, pinned);
    });

    test('is ignored while the address is being submitted', () async {
      await locateAt(_riyadh);
      unawaited(submit());

      cubit.pickLocation(pinned);

      expect(cubit.state.location, _riyadh);
      addresses.add.complete(const Right<Failure, Unit>(unit));
    });
  });

  group('submit', () {
    test('does nothing before a location is picked', () async {
      await submit();

      expect(addresses.added, isEmpty);
    });

    test('sends the normalised address with the picked location', () async {
      await locateAt(_riyadh);

      final Future<void> pending = submit();
      addresses.add.complete(const Right<Failure, Unit>(unit));
      await pending;

      expect(
        addresses.added.single,
        const NewAddress(
          type: AddressType.office,
          contactPersonName: 'Sara Customer',
          contactPersonNumber: '+966512345678',
          address: 'Olaya St 12',
          location: _riyadh,
        ),
      );
      expect(cubit.state.status, AddAddressStatus.success);
    });

    test('an out-of-coverage refusal keeps the location to retry', () async {
      await locateAt(_riyadh);

      final Future<void> pending = submit();
      addresses.add.complete(
        const Left<Failure, Unit>(ForbiddenFailure(code: outOfCoverageCode)),
      );
      await pending;

      expect(
        cubit.state,
        const AddAddressState(
          location: _riyadh,
          failure: ForbiddenFailure(code: outOfCoverageCode),
        ),
      );
      expect(cubit.state.failure!.isLocationProblem, isTrue);
    });

    test('ignores a second submit while one is in flight', () async {
      await locateAt(_riyadh);

      final Future<void> first = submit();
      await submit();
      addresses.add.complete(const Right<Failure, Unit>(unit));
      await first;

      expect(addresses.added, hasLength(1));
    });
  });

  group('isLocationProblem', () {
    test('is false for other refusals', () {
      expect(const ForbiddenFailure(code: 'phone').isLocationProblem, isFalse);
      expect(const NetworkFailure().isLocationProblem, isFalse);
    });
  });
}
