import 'package:equatable/equatable.dart';

import '../../../../core/location/geo_point.dart';
import 'c2c_parcel_quote.dart';
import 'c2c_parcel_status.dart';

/// One row of "my sent parcels" or "parcels sent to me".
class C2cParcelSummary extends Equatable {
  final int id;
  final String reference;
  final C2cViewerRole viewerRole;
  final C2cParcelStatus status;
  final int statusVersion;
  final String? title;

  /// The other side: the recipient for a sender, the sender for a
  /// recipient.
  final String? counterpartName;
  final String? destinationAddress;

  /// Null when the viewer doesn't see the price.
  final double? totalFee;
  final String currency;
  final DateTime? createdAt;

  const C2cParcelSummary({
    required this.id,
    required this.reference,
    required this.viewerRole,
    required this.status,
    required this.statusVersion,
    this.title,
    this.counterpartName,
    this.destinationAddress,
    this.totalFee,
    this.currency = 'SAR',
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    reference,
    viewerRole,
    status,
    statusVersion,
    title,
    counterpartName,
    destinationAddress,
    totalFee,
    currency,
    createdAt,
  ];
}

/// A page of parcels. [offset] is the 1-based page number.
class C2cParcelPage extends Equatable {
  final List<C2cParcelSummary> parcels;
  final int totalSize;
  final int limit;
  final int offset;

  const C2cParcelPage({
    required this.parcels,
    required this.totalSize,
    required this.limit,
    required this.offset,
  });

  bool get hasMore => offset * limit < totalSize;

  @override
  List<Object?> get props => [parcels, totalSize, limit, offset];
}

/// Which list to page through.
enum C2cParcelBox {
  /// Parcels the customer sends.
  sent,

  /// Parcels sent to the customer.
  received,
}

/// One end of the trip. The recipient's view of the sender is reduced to a
/// first name and a masked phone.
class C2cParty extends Equatable {
  final String? name;
  final String? phone;
  final String? address;
  final GeoPoint? location;

  /// Building, floor, apartment, notes — whatever was given.
  final Map<String, String> details;

  const C2cParty({
    this.name,
    this.phone,
    this.address,
    this.location,
    this.details = const <String, String>{},
  });

  @override
  List<Object?> get props => [name, phone, address, location, details];
}

class C2cDriver extends Equatable {
  final int? id;
  final String? name;
  final String? imageUrl;
  final String? phone;

  const C2cDriver({this.id, this.name, this.imageUrl, this.phone});

  @override
  List<Object?> get props => [id, name, imageUrl, phone];
}

/// One status change in the parcel's history.
class C2cTimelineEntry extends Equatable {
  final C2cParcelStatus status;
  final int? statusVersion;
  final DateTime? occurredAt;

  const C2cTimelineEntry({
    required this.status,
    this.statusVersion,
    this.occurredAt,
  });

  @override
  List<Object?> get props => [status, statusVersion, occurredAt];
}

/// What the viewer may do now, as the server decided.
class C2cParcelActions extends Equatable {
  final bool canCancel;
  final bool canRetryDispatch;
  final bool canRequestDeliveryOtp;
  final bool canRequestReturnOtp;
  final bool canOpenSupportCase;

  const C2cParcelActions({
    this.canCancel = false,
    this.canRetryDispatch = false,
    this.canRequestDeliveryOtp = false,
    this.canRequestReturnOtp = false,
    this.canOpenSupportCase = false,
  });

  @override
  List<Object?> get props => [
    canCancel,
    canRetryDispatch,
    canRequestDeliveryOtp,
    canRequestReturnOtp,
    canOpenSupportCase,
  ];
}

/// The parcel's own description. The fields only the sender may see
/// ([description], [declaredValue], [pickupInstructions]) are already null
/// in a recipient's response; [C2cParcelDetails] hides them again for a
/// recipient in case a response ever carries them.
class C2cParcelItem extends Equatable {
  final String? title;
  final String? description;
  final ParcelCategory? category;
  final double? weightKg;
  final bool isFragile;
  final double? declaredValue;
  final String? pickupInstructions;
  final String? deliveryInstructions;

  const C2cParcelItem({
    this.title,
    this.description,
    this.category,
    this.weightKg,
    this.isFragile = false,
    this.declaredValue,
    this.pickupInstructions,
    this.deliveryInstructions,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    category,
    weightKg,
    isFragile,
    declaredValue,
    pickupInstructions,
    deliveryInstructions,
  ];
}

class C2cPricing extends Equatable {
  final double totalFee;
  final String currency;
  final double? distanceKm;

  const C2cPricing({
    required this.totalFee,
    required this.currency,
    this.distanceKm,
  });

  @override
  List<Object?> get props => [totalFee, currency, distanceKm];
}

/// `GET /customer/c2c-parcels/{id}` — the full parcel, shaped by the
/// viewer's role.
class C2cParcelDetails extends Equatable {
  final int id;
  final String reference;
  final C2cViewerRole viewerRole;
  final C2cParcelStatus status;

  /// Sent back as `expected_version` with every command.
  final int statusVersion;
  final C2cParcelItem item;
  final C2cParty sender;
  final C2cParty recipient;

  /// Null for a recipient unless they pay.
  final C2cPricing? pricing;
  final C2cPaymentMethod paymentMethod;
  final int imageCount;

  /// Null until the viewer may see the driver.
  final C2cDriver? driver;
  final List<C2cTimelineEntry> timeline;
  final C2cParcelActions actions;

  const C2cParcelDetails({
    required this.id,
    required this.reference,
    required this.viewerRole,
    required this.status,
    required this.statusVersion,
    required this.item,
    required this.sender,
    required this.recipient,
    this.pricing,
    this.paymentMethod = C2cPaymentMethod.cashBySender,
    this.imageCount = 0,
    this.driver,
    this.timeline = const <C2cTimelineEntry>[],
    this.actions = const C2cParcelActions(),
  });

  bool get isSender => viewerRole == C2cViewerRole.sender;

  // --- Sender-only details (hidden from a recipient, per the API guide) ---

  String? get description => isSender ? item.description : null;
  double? get declaredValue => isSender ? item.declaredValue : null;
  String? get pickupInstructions => isSender ? item.pickupInstructions : null;

  // --- What the viewer may do now ---

  /// Only the sender, and only before the driver has the parcel. The
  /// server's flag, when it sends one, has the last word.
  bool get canCancel => isSender && status.isBeforePickup && actions.canCancel;

  bool get canRetryDispatch =>
      isSender &&
      status == C2cParcelStatus.assignmentFailed &&
      actions.canRetryDispatch;

  /// A delivery code (recipient or sender) or, while returning, the
  /// sender's return code.
  bool get canRequestOtp =>
      (status.allowsDeliveryOtp && actions.canRequestDeliveryOtp) ||
      (isSender && status.allowsReturnOtp && actions.canRequestReturnOtp);

  bool get canOpenSupportCase => actions.canOpenSupportCase;

  C2cParcelDetails copyWith({
    C2cParcelStatus? status,
    int? statusVersion,
    C2cDriver? driver,
    List<C2cTimelineEntry>? timeline,
  }) => C2cParcelDetails(
    id: id,
    reference: reference,
    viewerRole: viewerRole,
    status: status ?? this.status,
    statusVersion: statusVersion ?? this.statusVersion,
    item: item,
    sender: sender,
    recipient: recipient,
    pricing: pricing,
    paymentMethod: paymentMethod,
    imageCount: imageCount,
    driver: driver ?? this.driver,
    timeline: timeline ?? this.timeline,
    actions: actions,
  );

  @override
  List<Object?> get props => [
    id,
    reference,
    viewerRole,
    status,
    statusVersion,
    item,
    sender,
    recipient,
    pricing,
    paymentMethod,
    imageCount,
    driver,
    timeline,
    actions,
  ];
}

/// The driver's last reported position.
class C2cDriverLocation extends Equatable {
  final GeoPoint point;
  final double? heading;
  final DateTime? recordedAt;

  const C2cDriverLocation({required this.point, this.heading, this.recordedAt});

  @override
  List<Object?> get props => [point, heading, recordedAt];
}

/// `GET /customer/c2c-parcels/{id}/tracking` — the live view, polled when
/// the socket is down.
class C2cParcelTracking extends Equatable {
  final C2cParcelStatus status;
  final int statusVersion;
  final bool isTerminal;
  final List<C2cTimelineEntry> timeline;

  /// Null for a recipient.
  final GeoPoint? pickup;
  final GeoPoint? destination;
  final C2cDriver? driver;

  /// Null while the viewer may not see the driver, or after a final status.
  final C2cDriverLocation? driverLocation;
  final int? etaMinutes;

  /// How often to poll; null once the parcel is final.
  final int? pollingIntervalSeconds;

  const C2cParcelTracking({
    required this.status,
    required this.statusVersion,
    required this.isTerminal,
    this.timeline = const <C2cTimelineEntry>[],
    this.pickup,
    this.destination,
    this.driver,
    this.driverLocation,
    this.etaMinutes,
    this.pollingIntervalSeconds,
  });

  C2cParcelTracking withDriverLocation(C2cDriverLocation location) =>
      C2cParcelTracking(
        status: status,
        statusVersion: statusVersion,
        isTerminal: isTerminal,
        timeline: timeline,
        pickup: pickup,
        destination: destination,
        driver: driver,
        driverLocation: location,
        etaMinutes: etaMinutes,
        pollingIntervalSeconds: pollingIntervalSeconds,
      );

  @override
  List<Object?> get props => [
    status,
    statusVersion,
    isTerminal,
    timeline,
    pickup,
    destination,
    driver,
    driverLocation,
    etaMinutes,
    pollingIntervalSeconds,
  ];
}

/// Which code an OTP request produced.
enum C2cOtpPurpose {
  /// The recipient reads it to the driver to receive the parcel.
  delivery,

  /// The sender reads it to the driver to take the parcel back.
  returnToSender,
}

class C2cParcelOtp extends Equatable {
  final String code;
  final DateTime? expiresAt;
  final C2cOtpPurpose purpose;

  const C2cParcelOtp({
    required this.code,
    required this.purpose,
    this.expiresAt,
  });

  @override
  List<Object?> get props => [code, expiresAt, purpose];
}
