import 'package:equatable/equatable.dart';

import '../../../../core/location/geo_point.dart';

// Part of [Address]'s API, so callers needn't import it separately.
export '../../../../core/location/geo_point.dart';

enum AddressType { home, office, other }

/// A saved delivery address.
class Address extends Equatable {
  final int id;
  final AddressType type;
  final String contactPersonName;

  /// As stored server-side (E.164, e.g. `+966512345678`).
  final String contactPersonNumber;

  /// Free-text street address.
  final String address;

  /// Null when the backend returns unusable coordinates — the address is
  /// still listable and deletable.
  final GeoPoint? location;

  /// The delivery zone the server resolved for this address; orders to it
  /// are scoped to this zone. Null when the backend doesn't say.
  final int? zoneId;

  const Address({
    required this.id,
    required this.type,
    required this.contactPersonName,
    required this.contactPersonNumber,
    required this.address,
    this.location,
    this.zoneId,
  });

  @override
  List<Object?> get props => [
    id,
    type,
    contactPersonName,
    contactPersonNumber,
    address,
    location,
    zoneId,
  ];
}

/// An address to create. The server resolves its delivery zone from
/// [location] and refuses points outside every zone.
class NewAddress extends Equatable {
  final AddressType type;
  final String contactPersonName;

  /// E.164, e.g. `+966512345678` — see `SaudiPhone.toE164`.
  final String contactPersonNumber;
  final String address;
  final GeoPoint location;

  const NewAddress({
    required this.type,
    required this.contactPersonName,
    required this.contactPersonNumber,
    required this.address,
    required this.location,
  });

  @override
  List<Object?> get props => [
    type,
    contactPersonName,
    contactPersonNumber,
    address,
    location,
  ];
}
