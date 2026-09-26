import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/features/addresses/domain/entities/address.dart';
import 'package:ssm/features/addresses/domain/repos/address_repository.dart';
import 'package:ssm/features/addresses/presentation/cubit/addresses_cubit.dart';
import 'package:ssm/features/addresses/presentation/cubit/addresses_state.dart';
import 'package:flutter_test/flutter_test.dart';

const Address _home = Address(
  id: 1,
  type: AddressType.home,
  contactPersonName: 'Sara',
  contactPersonNumber: '+966512345678',
  address: 'Olaya St 12',
);

const Address _office = Address(
  id: 2,
  type: AddressType.office,
  contactPersonName: 'Sara',
  contactPersonNumber: '+966512345678',
  address: 'King Fahd Rd 5',
);

/// Answers through [Completer]s the test controls, so ordering is explicit
/// rather than timing-dependent.
class _FakeAddressRepository implements AddressRepository {
  Completer<Either<Failure, List<Address>>> list =
      Completer<Either<Failure, List<Address>>>();
  Completer<Either<Failure, Unit>> delete = Completer<Either<Failure, Unit>>();
  final List<int> deletedIds = <int>[];

  @override
  Future<Either<Failure, List<Address>>> getAddresses() => list.future;

  @override
  Future<Either<Failure, Unit>> addAddress(NewAddress address) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> deleteAddress(int id) {
    deletedIds.add(id);
    return delete.future;
  }
}

void main() {
  late _FakeAddressRepository repository;
  late AddressesCubit cubit;

  setUp(() {
    repository = _FakeAddressRepository();
    cubit = AddressesCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  Future<void> loadWith(List<Address> addresses) async {
    final Future<void> load = cubit.load();
    repository.list.complete(Right<Failure, List<Address>>(addresses));
    await load;
    repository.list = Completer<Either<Failure, List<Address>>>();
  }

  group('load', () {
    test('emits loading then the list', () async {
      final Future<void> expectation = expectLater(
        cubit.stream,
        emitsInOrder(<AddressesState>[
          const AddressesLoading(),
          const AddressesLoaded(addresses: <Address>[_home, _office]),
        ]),
      );

      await loadWith(<Address>[_home, _office]);
      await expectation;
    });

    test('emits the failure on a first load', () async {
      final Future<void> load = cubit.load();
      repository.list.complete(const Left(NetworkFailure()));
      await load;

      expect(cubit.state, const AddressesError(NetworkFailure()));
    });

    test('a failed refresh keeps the list on screen', () async {
      await loadWith(<Address>[_home]);

      final Future<void> refresh = cubit.load();
      repository.list.complete(const Left(ServerFailure()));
      await refresh;

      expect(cubit.state, const AddressesLoaded(addresses: <Address>[_home]));
    });
  });

  group('delete', () {
    test('marks the row as deleting while the request runs', () async {
      await loadWith(<Address>[_home, _office]);

      unawaited(cubit.delete(_home.id));
      await Future<void>.delayed(Duration.zero);

      expect(
        cubit.state,
        const AddressesLoaded(
          addresses: <Address>[_home, _office],
          deletingIds: <int>{1},
        ),
      );
    });

    test('removes the row once the server confirms', () async {
      await loadWith(<Address>[_home, _office]);

      final Future<void> delete = cubit.delete(_home.id);
      repository.delete.complete(const Right<Failure, Unit>(unit));
      await delete;

      expect(repository.deletedIds, <int>[1]);
      expect(cubit.state, const AddressesLoaded(addresses: <Address>[_office]));
    });

    test('keeps the row and reports the failure when refused', () async {
      await loadWith(<Address>[_home]);

      final Future<void> delete = cubit.delete(_home.id);
      repository.delete.complete(
        const Left<Failure, Unit>(ServerFailure(message: 'Not found')),
      );
      await delete;

      expect(
        cubit.state,
        const AddressesLoaded(
          addresses: <Address>[_home],
          deleteFailure: ServerFailure(message: 'Not found'),
        ),
      );
    });

    test('ignores a second delete of the same row', () async {
      await loadWith(<Address>[_home]);

      final Future<void> first = cubit.delete(_home.id);
      await cubit.delete(_home.id);
      repository.delete.complete(const Right<Failure, Unit>(unit));
      await first;

      expect(repository.deletedIds, <int>[1]);
    });

    test('does nothing before the list has loaded', () async {
      await cubit.delete(_home.id);

      expect(repository.deletedIds, isEmpty);
    });
  });
}
