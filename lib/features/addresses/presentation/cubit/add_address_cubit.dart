import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/location/location_repository.dart';
import '../../../../core/utils/saudi_phone.dart';
import '../../../../core/utils/string_extension.dart';
import '../../domain/entities/address.dart';
import '../../domain/repos/address_repository.dart';
import 'add_address_state.dart';

/// Screen-scoped (one instance per Add Address route). Takes raw form input
/// and normalises it into a [NewAddress] before calling the repository.
class AddAddressCubit extends Cubit<AddAddressState> {
  final AddressRepository addressRepository;
  final LocationRepository locationRepository;

  AddAddressCubit({
    required this.addressRepository,
    required this.locationRepository,
  }) : super(const AddAddressState());

  Future<void> locate() async {
    if (state.isBusy) return;
    emit(
      AddAddressState(
        status: AddAddressStatus.locating,
        location: state.location,
      ),
    );
    final Either<Failure, GeoPoint> result = await locationRepository
        .getCurrentLocation();
    if (isClosed) return;
    result.fold(
      (Failure failure) =>
          emit(AddAddressState(location: state.location, failure: failure)),
      (GeoPoint location) => emit(
        AddAddressState(
          location: location,
          locationSource: LocationSource.device,
        ),
      ),
    );
  }

  /// The customer placed the map pin. Clears a previous location problem
  /// (e.g. "outside our delivery area") — they're fixing it. Ignored while
  /// the address is being submitted.
  void pickLocation(GeoPoint location) {
    if (state.status == AddAddressStatus.submitting ||
        state.location == location) {
      return;
    }
    emit(AddAddressState(status: state.status, location: location));
  }

  /// No-op until a location has been picked — the form requires one.
  Future<void> submit({
    required AddressType type,
    required String contactPersonName,
    required String contactPersonNumber,
    required String address,
  }) async {
    final GeoPoint? location = state.location;
    if (state.isBusy || location == null) return;
    emit(
      AddAddressState(status: AddAddressStatus.submitting, location: location),
    );
    final Either<Failure, Unit> result = await addressRepository.addAddress(
      NewAddress(
        type: type,
        contactPersonName: contactPersonName.collapseWhitespace(),
        contactPersonNumber: SaudiPhone.toE164(contactPersonNumber),
        address: address.trim(),
        location: location,
      ),
    );
    if (isClosed) return;
    result.fold(
      (Failure failure) =>
          emit(AddAddressState(location: location, failure: failure)),
      (_) => emit(
        AddAddressState(status: AddAddressStatus.success, location: location),
      ),
    );
  }
}
