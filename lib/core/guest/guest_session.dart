import 'package:equatable/equatable.dart';

/// A guest's proof of ownership for cart and order calls made without an
/// account — `POST /auth/guest/request`.
///
/// [guestId] alone is sequential and no longer accepted by the backend: every
/// guest request must also carry [token] as the `X-Guest-Token` header.
class GuestSession extends Equatable {
  final int guestId;
  final String token;

  /// Null when the backend didn't say — treated as never expiring until the
  /// backend rejects it.
  final DateTime? expiresAt;

  const GuestSession({
    required this.guestId,
    required this.token,
    this.expiresAt,
  });

  /// Renew this long before [expiresAt], so a request never leaves with a
  /// token that expires while it's in flight.
  static const Duration expiryMargin = Duration(minutes: 1);

  bool isUsableAt(DateTime now) {
    final DateTime? expiry = expiresAt;
    return expiry == null || now.isBefore(expiry.subtract(expiryMargin));
  }

  @override
  List<Object?> get props => [guestId, token, expiresAt];
}
