import 'package:equatable/equatable.dart';

import '../../../../core/location/geo_point.dart';
import 'c2c_parcel_quote.dart';
import 'c2c_parcel_status.dart';

/// One side of a parcel being created — who hands it over, or receives it,
/// and where.
class C2cContact extends Equatable {
  final String name;
  final String phone;
  final String address;
  final GeoPoint location;
  final String? building;
  final String? floor;
  final String? apartment;
  final String? notes;

  const C2cContact({
    required this.name,
    required this.phone,
    required this.address,
    required this.location,
    this.building,
    this.floor,
    this.apartment,
    this.notes,
  });

  @override
  List<Object?> get props => [
    name,
    phone,
    address,
    location,
    building,
    floor,
    apartment,
    notes,
  ];
}

enum C2cPhotoIssue { tooLarge, unsupportedType }

/// Where a parcel photo comes from.
enum C2cPhotoSource { camera, gallery }

/// A photo of the parcel, picked on the device.
class C2cParcelPhoto extends Equatable {
  final String path;
  final String fileName;
  final int sizeBytes;

  const C2cParcelPhoto({
    required this.path,
    required this.fileName,
    required this.sizeBytes,
  });

  /// The backend's limits: 1–5 photos, each at most 5 MB.
  static const int maxBytes = 5 * 1024 * 1024;
  static const int maxCount = 5;

  /// The formats the backend accepts (it checks the real MIME type).
  static const Set<String> allowedExtensions = <String>{
    'jpg',
    'jpeg',
    'png',
    'webp',
  };

  /// Lower-case, without the dot; empty when the name has none.
  String get extension {
    final int dot = fileName.lastIndexOf('.');
    return dot < 0 ? '' : fileName.substring(dot + 1).toLowerCase();
  }

  /// Why the backend would refuse this photo, or null when it's fine.
  C2cPhotoIssue? get issue {
    if (!allowedExtensions.contains(extension)) {
      return C2cPhotoIssue.unsupportedType;
    }
    if (sizeBytes > maxBytes) return C2cPhotoIssue.tooLarge;
    return null;
  }

  @override
  List<Object?> get props => [path, fileName, sizeBytes];
}

/// Everything `POST /customer/c2c-parcels` needs. The size, weight and
/// ends come from the quote's [request], so the price can't drift from
/// what the customer accepted.
class C2cParcelDraft extends Equatable {
  final C2cQuoteRequest request;
  final C2cContact sender;
  final C2cContact recipient;

  /// Required by the server, ≤120 characters.
  final String title;
  final String? description;
  final double? declaredValue;
  final String? pickupInstructions;
  final String? deliveryInstructions;
  final C2cPaymentMethod paymentMethod;
  final List<C2cParcelPhoto> photos;

  /// The customer confirmed the parcel holds no prohibited items.
  final bool prohibitedItemsAcknowledged;

  /// Makes the server refuse a price that changed since the quote (409).
  final String? quoteToken;

  const C2cParcelDraft({
    required this.request,
    required this.sender,
    required this.recipient,
    required this.title,
    required this.photos,
    required this.prohibitedItemsAcknowledged,
    this.description,
    this.declaredValue,
    this.pickupInstructions,
    this.deliveryInstructions,
    this.paymentMethod = C2cPaymentMethod.cashBySender,
    this.quoteToken,
  });

  @override
  List<Object?> get props => [
    request,
    sender,
    recipient,
    title,
    description,
    declaredValue,
    pickupInstructions,
    deliveryInstructions,
    paymentMethod,
    photos,
    prohibitedItemsAcknowledged,
    quoteToken,
  ];
}
