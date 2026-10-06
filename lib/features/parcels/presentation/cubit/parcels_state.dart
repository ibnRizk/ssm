import 'package:equatable/equatable.dart';

import '../../../../core/delivery_otp/delivery_otp.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/parcel.dart';

sealed class ParcelsState extends Equatable {
  const ParcelsState();

  @override
  List<Object?> get props => [];
}

final class ParcelsInitial extends ParcelsState {
  const ParcelsInitial();
}

final class ParcelsLoading extends ParcelsState {
  const ParcelsLoading();
}

final class ParcelsError extends ParcelsState {
  final Failure failure;

  const ParcelsError(this.failure);

  @override
  List<Object?> get props => [failure];
}

final class ParcelsLoaded extends ParcelsState {
  final List<Parcel> parcels;
  final DropoffStatus dropoff;

  /// The delivery code of each parcel that is out for delivery, by id.
  /// Parcels without an entry show no code.
  final Map<int, DeliveryOtpState> otps;

  /// A manual refresh ("Update now") is running; the list stays visible.
  final bool isRefreshing;

  /// The last refresh failed — one-shot, for a snack bar. Every [copyWith]
  /// clears it unless passed again.
  final Failure? refreshFailure;

  const ParcelsLoaded({
    required this.parcels,
    this.dropoff = const DropoffIdle(),
    this.otps = const <int, DeliveryOtpState>{},
    this.isRefreshing = false,
    this.refreshFailure,
  });

  /// See [Parcel.dropoffTarget].
  Parcel? get dropoffTarget => Parcel.dropoffTarget(parcels);

  ParcelsLoaded copyWith({
    List<Parcel>? parcels,
    DropoffStatus? dropoff,
    Map<int, DeliveryOtpState>? otps,
    bool? isRefreshing,
    Failure? refreshFailure,
  }) => ParcelsLoaded(
    parcels: parcels ?? this.parcels,
    dropoff: dropoff ?? this.dropoff,
    otps: otps ?? this.otps,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    refreshFailure: refreshFailure,
  );

  @override
  List<Object?> get props => [
    parcels,
    dropoff,
    otps,
    isRefreshing,
    refreshFailure,
  ];
}

// --- Sending a drop-off location ---

enum DropoffStage { locating, sending }

sealed class DropoffStatus extends Equatable {
  const DropoffStatus();

  @override
  List<Object?> get props => [];
}

final class DropoffIdle extends DropoffStatus {
  const DropoffIdle();
}

final class DropoffInProgress extends DropoffStatus {
  final int parcelId;
  final DropoffStage stage;

  const DropoffInProgress(this.parcelId, this.stage);

  @override
  List<Object?> get props => [parcelId, stage];
}

final class DropoffSent extends DropoffStatus {
  final int parcelId;

  const DropoffSent(this.parcelId);

  @override
  List<Object?> get props => [parcelId];
}

/// A location failure (GPS off, access denied) or the API's refusal (422
/// invalid coordinates / already delivered, 404 not yours).
final class DropoffFailed extends DropoffStatus {
  final int parcelId;
  final Failure failure;

  const DropoffFailed(this.parcelId, this.failure);

  @override
  List<Object?> get props => [parcelId, failure];
}
