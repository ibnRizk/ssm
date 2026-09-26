import 'package:equatable/equatable.dart';

import '../../../../core/location/geo_point.dart';
import 'prescription_image.dart';

/// Why a pharmacy request can't be sent yet.
enum PharmacyRequestIssue { noPharmacy, noAddress, noContent }

/// A request for a pharmacy to quote and deliver what the customer needs.
/// The recipient and delivery details come from one of their saved
/// addresses.
class PharmacyRequestDraft extends Equatable {
  final int pharmacyStoreId;

  /// Trimmed; null when the customer only attached a prescription.
  final String? requestText;
  final PrescriptionImage? prescription;
  final String recipientName;

  /// E.164, e.g. `+966512345678`.
  final String recipientPhone;
  final String deliveryAddress;

  /// Null when the saved address has no usable pin.
  final GeoPoint? location;

  const PharmacyRequestDraft({
    required this.pharmacyStoreId,
    required this.recipientName,
    required this.recipientPhone,
    required this.deliveryAddress,
    this.requestText,
    this.prescription,
    this.location,
  });

  /// The backend needs a text, an image, or both.
  static bool hasContent({
    required String? requestText,
    required PrescriptionImage? prescription,
  }) => (requestText?.trim().isNotEmpty ?? false) || prescription != null;

  @override
  List<Object?> get props => [
    pharmacyStoreId,
    requestText,
    prescription,
    recipientName,
    recipientPhone,
    deliveryAddress,
    location,
  ];
}

/// The backend's answer to a sent request (HTTP 201).
class PharmacyRequestReceipt extends Equatable {
  final int id;

  /// The price disclaimer the backend sends back — the quoted price may
  /// change with what the pharmacy actually has. Null if it sent none.
  final String? warning;

  const PharmacyRequestReceipt({required this.id, this.warning});

  @override
  List<Object?> get props => [id, warning];
}
