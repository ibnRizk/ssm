import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// The code the customer tells the courier to complete a delivery — of an
/// order or a parcel. Requesting another one invalidates this one.
class DeliveryOtp extends Equatable {
  final String code;
  final DateTime? expiresAt;

  const DeliveryOtp({required this.code, this.expiresAt});

  @override
  List<Object?> get props => [code, expiresAt];
}

/// Fetching a [DeliveryOtp], for an order or a parcel that is out for
/// delivery.
sealed class DeliveryOtpState extends Equatable {
  const DeliveryOtpState();

  @override
  List<Object?> get props => [];
}

final class OtpIdle extends DeliveryOtpState {
  const OtpIdle();
}

final class OtpLoading extends DeliveryOtpState {
  const OtpLoading();
}

final class OtpReady extends DeliveryOtpState {
  final DeliveryOtp otp;

  const OtpReady(this.otp);

  @override
  List<Object?> get props => [otp];
}

/// The backend answered 409 `otp-not-available` — the order or parcel isn't out for
/// delivery on its side (yet), or it has no code for this delivery.
final class OtpUnavailable extends DeliveryOtpState {
  const OtpUnavailable();
}

final class OtpFailed extends DeliveryOtpState {
  final Failure failure;

  const OtpFailed(this.failure);

  @override
  List<Object?> get props => [failure];
}
