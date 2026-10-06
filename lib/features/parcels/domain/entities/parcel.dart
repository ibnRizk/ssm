import 'package:equatable/equatable.dart';

import '../../../../core/location/geo_point.dart';

/// Where a warehouse parcel is. The API doesn't document its raw values;
/// see `ParcelModel.statusFromWire` for the mapping.
///
/// **Declaration order is delivery order** — the tracking timeline compares
/// positions (`index`) to decide which steps are done. A unit test pins
/// this order; add a new stage where it happens in real life.
enum ParcelStatus {
  /// Created by an admin, not yet received at the warehouse.
  processing,
  atWarehouse,
  outForDelivery,
  delivered,
}

enum ParcelPaymentType {
  prepaid,

  /// Cash on delivery — [Parcel.codAmount] is due to the driver.
  cod,
}

/// A parcel an admin registered at the SSM warehouse, delivered by an SSM
/// driver. Belongs to the customer by id or recipient phone.
class Parcel extends Equatable {
  final int id;

  /// Shown to the customer, e.g. `SSM-P2048`. Falls back to the id.
  final String reference;
  final ParcelStatus status;
  final ParcelPaymentType paymentType;

  /// Zero for prepaid parcels.
  final double codAmount;

  /// What the customer pays for delivery — always 0 per the API guide.
  final double deliveryFee;
  final String currency;

  /// The drop-off the customer sent, if any.
  final GeoPoint? dropoffLocation;
  final String? deliveryAddress;
  final DateTime? updatedAt;

  const Parcel({
    required this.id,
    required this.reference,
    required this.status,
    required this.paymentType,
    required this.codAmount,
    required this.deliveryFee,
    required this.currency,
    this.dropoffLocation,
    this.deliveryAddress,
    this.updatedAt,
  });

  bool get hasDropoffLocation => dropoffLocation != null;

  /// The courier is on the way and completes the delivery with the
  /// customer's delivery code.
  bool get needsDeliveryOtp => status == ParcelStatus.outForDelivery;

  /// The backend refuses a drop-off once the parcel is delivered.
  bool get acceptsDropoffLocation => status != ParcelStatus.delivered;

  /// Waiting on the customer: at the warehouse, no drop-off sent yet.
  bool get awaitsDropoffLocation =>
      status == ParcelStatus.atWarehouse && !hasDropoffLocation;

  /// The parcel the "send my location" card acts on: the first (newest, in
  /// API order) parcel at the warehouse still waiting for a drop-off, else
  /// the first one at the warehouse — so the customer can correct a
  /// location already sent. Null when none is at the warehouse.
  static Parcel? dropoffTarget(List<Parcel> parcels) {
    Parcel? atWarehouse;
    for (final Parcel parcel in parcels) {
      if (parcel.awaitsDropoffLocation) return parcel;
      if (parcel.status == ParcelStatus.atWarehouse) {
        atWarehouse ??= parcel;
      }
    }
    return atWarehouse;
  }

  @override
  List<Object?> get props => [
    id,
    reference,
    status,
    paymentType,
    codAmount,
    deliveryFee,
    currency,
    dropoffLocation,
    deliveryAddress,
    updatedAt,
  ];
}

/// What the customer sends for a parcel's delivery.
class ParcelDropoff extends Equatable {
  final GeoPoint location;

  /// Street, building, gate — free text for the driver.
  final String deliveryAddress;
  final String? notes;

  const ParcelDropoff({
    required this.location,
    required this.deliveryAddress,
    this.notes,
  });

  @override
  List<Object?> get props => [location, deliveryAddress, notes];
}
