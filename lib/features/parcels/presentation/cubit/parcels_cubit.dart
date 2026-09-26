import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/location/geo_point.dart';
import '../../../../core/location/location_repository.dart';
import '../../domain/entities/parcel.dart';
import '../../domain/repos/parcels_repository.dart';
import 'parcels_state.dart';

/// Screen-scoped (provided at the Parcels tab's route).
class ParcelsCubit extends Cubit<ParcelsState> {
  final ParcelsRepository parcelsRepository;
  final LocationRepository locationRepository;

  ParcelsCubit({
    required this.parcelsRepository,
    required this.locationRepository,
  }) : super(const ParcelsInitial());

  bool _fetching = false;

  /// A drop-off was accepted while a fetch was already in flight. That
  /// fetch may have been answered before the server had the location, so
  /// one more runs as soon as it finishes.
  bool _reloadOwed = false;

  /// First load shows a spinner; later calls ("Update now", after a
  /// drop-off) keep the list visible and report a failure without
  /// replacing it. A call while one is in flight is ignored — see
  /// [_reloadAfterDropoff] for the case where that would lose data.
  Future<void> fetchParcels() async {
    if (_fetching) return;
    _fetching = true;
    final ParcelsState before = state;
    if (before is ParcelsLoaded) {
      emit(before.copyWith(isRefreshing: true));
    } else {
      emit(const ParcelsLoading());
    }

    final Either<Failure, List<Parcel>> result = await parcelsRepository
        .getParcels();

    _fetching = false;
    if (isClosed) return;
    final ParcelsState current = state;
    result.fold(
      (Failure failure) => emit(
        current is ParcelsLoaded
            ? current.copyWith(isRefreshing: false, refreshFailure: failure)
            : ParcelsError(failure),
      ),
      (List<Parcel> parcels) => emit(
        current is ParcelsLoaded
            ? current.copyWith(parcels: parcels, isRefreshing: false)
            : ParcelsLoaded(parcels: parcels),
      ),
    );

    if (_reloadOwed) {
      _reloadOwed = false;
      await fetchParcels();
    }
  }

  /// Refetches after an accepted drop-off. If a fetch is already running
  /// it started before the send, so instead of being skipped, the reload is
  /// owed and runs when that fetch ends.
  Future<void> _reloadAfterDropoff() async {
    if (_fetching) {
      _reloadOwed = true;
      return;
    }
    await fetchParcels();
  }

  /// Reads the device location and sends it as [parcelId]'s drop-off,
  /// then refetches the list so the timeline reflects the server.
  Future<void> sendDropoffLocation(
    int parcelId, {
    required String deliveryAddress,
    String? notes,
  }) async {
    final ParcelsState before = state;
    if (before is! ParcelsLoaded || before.dropoff is DropoffInProgress) {
      return;
    }
    emit(
      before.copyWith(
        dropoff: DropoffInProgress(parcelId, DropoffStage.locating),
      ),
    );

    final Either<Failure, GeoPoint> located = await locationRepository
        .getCurrentLocation();
    if (isClosed) return;

    final Either<Failure, Unit> result = await located.fold(
      (Failure failure) async => Left<Failure, Unit>(failure),
      (GeoPoint location) {
        _updateLoaded(
          (ParcelsLoaded s) => s.copyWith(
            dropoff: DropoffInProgress(parcelId, DropoffStage.sending),
          ),
        );
        return parcelsRepository.sendDropoff(
          parcelId,
          ParcelDropoff(
            location: location,
            deliveryAddress: deliveryAddress.trim(),
            notes: notes?.trim(),
          ),
        );
      },
    );
    if (isClosed) return;

    _updateLoaded(
      (ParcelsLoaded s) => s.copyWith(
        dropoff: result.fold(
          (Failure failure) => DropoffFailed(parcelId, failure),
          (_) => DropoffSent(parcelId),
        ),
      ),
    );
    if (result.isRight()) await _reloadAfterDropoff();
  }

  void _updateLoaded(ParcelsLoaded Function(ParcelsLoaded) update) {
    final ParcelsState current = state;
    if (current is ParcelsLoaded) emit(update(current));
  }
}
