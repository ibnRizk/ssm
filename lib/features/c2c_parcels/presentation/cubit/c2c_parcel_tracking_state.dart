import 'package:equatable/equatable.dart';

import '../../../../core/delivery_otp/delivery_otp.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/c2c_parcel.dart';

sealed class C2cParcelTrackingState extends Equatable {
  const C2cParcelTrackingState();

  @override
  List<Object?> get props => [];
}

final class C2cTrackingLoading extends C2cParcelTrackingState {
  const C2cTrackingLoading();
}

/// The parcel itself couldn't be read — 404 for someone else's parcel.
final class C2cTrackingError extends C2cParcelTrackingState {
  final Failure failure;

  const C2cTrackingError(this.failure);

  @override
  List<Object?> get props => [failure];
}

final class C2cTrackingLoaded extends C2cParcelTrackingState {
  final C2cParcelDetails details;

  /// The live view; null when it couldn't be read yet — the screen then
  /// works from [details] alone.
  final C2cParcelTracking? tracking;

  /// The delivery code — or, while returning, the sender's return code.
  final DeliveryOtpState otp;
  final C2cCommandStatus command;

  const C2cTrackingLoaded({
    required this.details,
    this.tracking,
    this.otp = const OtpIdle(),
    this.command = const C2cCommandIdle(),
  });

  C2cTrackingLoaded copyWith({
    C2cParcelDetails? details,
    C2cParcelTracking? tracking,
    DeliveryOtpState? otp,
    C2cCommandStatus? command,
  }) => C2cTrackingLoaded(
    details: details ?? this.details,
    tracking: tracking ?? this.tracking,
    otp: otp ?? this.otp,
    command: command ?? this.command,
  );

  @override
  List<Object?> get props => [details, tracking, otp, command];
}

// --- Cancel, retry dispatch, support ---

enum C2cCommand { cancel, retryDispatch, support }

sealed class C2cCommandStatus extends Equatable {
  const C2cCommandStatus();

  @override
  List<Object?> get props => [];
}

final class C2cCommandIdle extends C2cCommandStatus {
  const C2cCommandIdle();
}

final class C2cCommandInProgress extends C2cCommandStatus {
  final C2cCommand command;

  const C2cCommandInProgress(this.command);

  @override
  List<Object?> get props => [command];
}

final class C2cCommandDone extends C2cCommandStatus {
  final C2cCommand command;

  const C2cCommandDone(this.command);

  @override
  List<Object?> get props => [command];
}

/// A `stale_version` refusal has already triggered a refresh, so the
/// screen shows the parcel's real status next to the message.
final class C2cCommandFailed extends C2cCommandStatus {
  final C2cCommand command;
  final Failure failure;

  const C2cCommandFailed(this.command, this.failure);

  @override
  List<Object?> get props => [command, failure];
}
