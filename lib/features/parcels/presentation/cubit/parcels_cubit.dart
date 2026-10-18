import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/delivery_otp/delivery_otp.dart';
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

  /// A parcel's details opened before the list loaded — see [refreshParcel].
  int? _parcelRefreshOwed;

  /// Periodic poll while the tab is open and there are active parcels.
  Timer? _pollTimer;
  static const Duration _pollInterval = Duration(seconds: 30);

  /// Call when the Parcels tab becomes visible. Starts a periodic refresh
  /// so status changes (driver picks up, OTP required) are reflected without
  /// the customer tapping "Update now".
  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      if (_hasActiveParcels) unawaited(fetchParcels(silent: true));
    });
  }

  /// Call when the Parcels tab is hidden or the app goes to background.
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  bool get _hasActiveParcels {
    final ParcelsState s = state;
    if (s is! ParcelsLoaded) return false;
    return s.parcels.any((Parcel p) => p.status != ParcelStatus.delivered);
  }

  /// First load shows a spinner; later calls ("Update now", after a
  /// drop-off) keep the list visible and report a failure without
  /// replacing it. A call while one is in flight is ignored — see
  /// [_reloadAfterDropoff] for the case where that would lose data.
  ///
  /// [silent] — when true, a refresh failure while already loaded keeps the
  /// list without setting [ParcelsLoaded.refreshFailure]. Use for timer-driven
  /// background polls that the customer didn't initiate, so a snack bar isn't
  /// shown on every offline tick.
  Future<void> fetchParcels({bool silent = false}) async {
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
            ? silent
                ? current.copyWith(isRefreshing: false)
                : current.copyWith(isRefreshing: false, refreshFailure: failure)
            : ParcelsError(failure),
      ),
      (List<Parcel> parcels) => emit(
        current is ParcelsLoaded
            ? current.copyWith(parcels: parcels, isRefreshing: false)
            : ParcelsLoaded(parcels: parcels),
      ),
    );

    if (isClosed) return;
    _syncDeliveryOtps();

    if (_reloadOwed) {
      _reloadOwed = false;
      await fetchParcels();
    } else if (state is ParcelsLoaded) {
      if (_parcelRefreshOwed case final int parcelId) {
        _parcelRefreshOwed = null;
        await refreshParcel(parcelId);
      }
    }
  }

  /// Refetches one parcel (its details screen opened) and swaps it into the
  /// list, appended when it isn't on the first page. Asked before the list
  /// is loaded, it runs once the list is. A failure is reported like a
  /// failed refresh, keeping what's shown.
  Future<void> refreshParcel(int parcelId) async {
    if (state is! ParcelsLoaded) {
      _parcelRefreshOwed = parcelId;
      return;
    }
    final Either<Failure, Parcel> result = await parcelsRepository.getParcel(
      parcelId,
    );
    if (isClosed) return;
    result.fold(
      (Failure failure) =>
          _updateLoaded((ParcelsLoaded s) => s.copyWith(refreshFailure: failure)),
      (Parcel parcel) => _updateLoaded(
        (ParcelsLoaded s) => s.copyWith(parcels: _upsert(s.parcels, parcel)),
      ),
    );
    _syncDeliveryOtps();
  }

  static List<Parcel> _upsert(List<Parcel> parcels, Parcel parcel) {
    final int index = parcels.indexWhere((Parcel p) => p.id == parcel.id);
    if (index < 0) return <Parcel>[...parcels, parcel];
    return <Parcel>[...parcels]..[index] = parcel;
  }

  /// Fetches [parcelId]'s delivery code — a new one replaces the old, so
  /// only on the customer's request once a code has been shown. Only while
  /// the parcel is out for delivery, and not while a request is on its way.
  Future<void> requestDeliveryOtp(int parcelId) async {
    final ParcelsState before = state;
    if (before is! ParcelsLoaded ||
        !_isOutForDelivery(before, parcelId) ||
        before.otps[parcelId] is OtpLoading) {
      return;
    }
    emit(before.copyWith(otps: _withOtp(before, parcelId, const OtpLoading())));

    final Either<Failure, DeliveryOtp> result = await parcelsRepository
        .requestDeliveryOtp(parcelId);
    if (isClosed) return;
    final ParcelsState latest = state;
    // Delivered, or gone from the list, while the code was coming.
    if (latest is! ParcelsLoaded || !_isOutForDelivery(latest, parcelId)) {
      return;
    }
    final DeliveryOtpState otp = result.fold(
      (Failure failure) => switch (failure) {
        // 409 `otp-not-available`: not out for delivery on the server yet.
        // 404: the parcel has no code to give (or isn't this customer's).
        ConflictFailure() || NotFoundFailure() => const OtpUnavailable(),
        _ => OtpFailed(failure),
      },
      OtpReady.new,
    );
    emit(latest.copyWith(otps: _withOtp(latest, parcelId, otp)));
  }

  /// Keeps a code only for parcels still out for delivery, and fetches the
  /// first code of each parcel that just went out.
  void _syncDeliveryOtps() {
    final ParcelsState current = state;
    if (current is! ParcelsLoaded) return;
    final Map<int, DeliveryOtpState> otps = <int, DeliveryOtpState>{
      for (final Parcel parcel in current.parcels)
        if (parcel.needsDeliveryOtp)
          parcel.id: current.otps[parcel.id] ?? const OtpIdle(),
    };
    final bool changed =
        otps.length != current.otps.length ||
        otps.entries.any(
          (MapEntry<int, DeliveryOtpState> e) => current.otps[e.key] != e.value,
        );
    if (changed) emit(current.copyWith(otps: otps));
    for (final MapEntry<int, DeliveryOtpState> entry in otps.entries) {
      if (entry.value is OtpIdle) unawaited(requestDeliveryOtp(entry.key));
    }
  }

  static bool _isOutForDelivery(ParcelsLoaded state, int parcelId) =>
      state.parcels.any((Parcel p) => p.id == parcelId && p.needsDeliveryOtp);

  static Map<int, DeliveryOtpState> _withOtp(
    ParcelsLoaded state,
    int parcelId,
    DeliveryOtpState otp,
  ) => <int, DeliveryOtpState>{...state.otps, parcelId: otp};

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

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}
