import '../api/json_readers.dart';
import '../error/exceptions.dart';
import 'delivery_otp.dart';

/// `{ "delivery_otp": { "challenge_id", "otp", "expires_at" } }` — the body
/// of every delivery-OTP request, for orders and parcels alike. A numeric
/// `otp` keeps its leading zeros. Throws [ServerException] without a code.
DeliveryOtp parseDeliveryOtp(dynamic json) {
  final dynamic otp = json is Map ? json['delivery_otp'] : null;
  final String? code = otp is Map
      ? switch (otp['otp']) {
          final int v => v.toString().padLeft(6, '0'),
          final dynamic v => jsonString(v),
        }
      : null;
  if (code == null) throw const ServerException();
  final String? expiresAt = jsonString((otp as Map)['expires_at']);
  return DeliveryOtp(
    code: code,
    expiresAt: expiresAt == null ? null : DateTime.tryParse(expiresAt),
  );
}
