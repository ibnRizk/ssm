import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/address.dart';
import '../../domain/repos/address_repository.dart';
import 'addresses_state.dart';

/// Screen-scoped (one instance per My Addresses route).
class AddressesCubit extends Cubit<AddressesState> {
  final AddressRepository repository;

  AddressesCubit({required this.repository}) : super(const AddressesInitial());

  bool _loading = false;

  /// A refresh while the list is on screen keeps it visible instead of
  /// flashing the spinner.
  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    if (state is! AddressesLoaded) emit(const AddressesLoading());

    final Either<Failure, List<Address>> result = await repository
        .getAddresses();

    _loading = false;
    if (isClosed) return;
    result.fold(
      (Failure failure) {
        // Keep a list already on screen; a failed refresh isn't worth
        // replacing it with an error page.
        if (state is! AddressesLoaded) emit(AddressesError(failure));
      },
      (List<Address> addresses) => emit(
        AddressesLoaded(addresses: addresses, deletingIds: _currentDeletingIds),
      ),
    );
  }

  /// Removes the row locally only once the server confirms.
  Future<void> delete(int id) async {
    final AddressesState before = state;
    if (before is! AddressesLoaded || before.deletingIds.contains(id)) return;
    emit(
      AddressesLoaded(
        addresses: before.addresses,
        deletingIds: <int>{...before.deletingIds, id},
      ),
    );

    final Either<Failure, Unit> result = await repository.deleteAddress(id);
    if (isClosed) return;

    // Re-read: a refresh or another delete may have landed meanwhile.
    final AddressesState after = state;
    if (after is! AddressesLoaded) return;
    final Set<int> stillDeleting = <int>{...after.deletingIds}..remove(id);
    result.fold(
      (Failure failure) => emit(
        AddressesLoaded(
          addresses: after.addresses,
          deletingIds: stillDeleting,
          deleteFailure: failure,
        ),
      ),
      (_) => emit(
        AddressesLoaded(
          addresses: after.addresses
              .where((Address a) => a.id != id)
              .toList(growable: false),
          deletingIds: stillDeleting,
        ),
      ),
    );
  }

  Set<int> get _currentDeletingIds {
    final AddressesState current = state;
    return current is AddressesLoaded ? current.deletingIds : const <int>{};
  }
}
