import '../../../../core/api/json_readers.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/location/geo_point.dart';
import '../../domain/entities/c2c_parcel.dart';
import '../../domain/entities/c2c_parcel_quote.dart';
import '../../domain/entities/c2c_parcel_status.dart';

/// Readers for the `/customer/c2c-parcels` responses (see the API guide's
/// section 3). Every body is `{ "data": … }`; a bare object is read too.
/// Numbers may arrive as strings, so every read is lenient, and a field the
/// screens can do without is left null rather than failing the response.
abstract final class C2cParcelModels {
  /// `GET /`, `GET /recipient` → `{ data: [...], total_size, limit,
  /// offset }`. Throws [ServerException] without a `data` list.
  static C2cParcelPage pageFromJson(
    dynamic json, {
    required int limit,
    required int offset,
  }) {
    final dynamic list = json is Map ? json['data'] : null;
    if (list is! List) throw const ServerException();
    final List<C2cParcelSummary> parcels = list
        .map(_summaryFromJson)
        .whereType<C2cParcelSummary>()
        .toList(growable: false);
    return C2cParcelPage(
      parcels: parcels,
      totalSize: jsonInt((json as Map)['total_size']) ?? parcels.length,
      limit: jsonInt(json['limit']) ?? limit,
      offset: jsonInt(json['offset']) ?? offset,
    );
  }

  static C2cParcelSummary? _summaryFromJson(dynamic json) {
    if (json is! Map) return null;
    final int? id = jsonInt(json['id']);
    if (id == null) return null;
    return C2cParcelSummary(
      id: id,
      reference: jsonString(json['reference']) ?? '#$id',
      viewerRole: C2cViewerRole.fromWire(jsonString(json['viewer_role'])),
      status: C2cParcelStatus.fromWire(jsonString(json['status'])),
      statusVersion: jsonInt(json['status_version']) ?? 0,
      title: jsonString(json['title']),
      counterpartName: jsonString(json['counterpart_name']),
      destinationAddress: jsonString(json['destination_address']),
      totalFee: jsonDouble(json['total_fee']),
      currency: jsonString(json['currency']) ?? 'SAR',
      createdAt: _date(json['created_at']),
    );
  }

  /// `GET /{id}` and the 201 of create. Throws [ServerException] without
  /// an id.
  static C2cParcelDetails detailsFromJson(dynamic json) {
    final Map<dynamic, dynamic> data = _data(json);
    final int? id = jsonInt(data['id']);
    if (id == null) throw const ServerException();

    final C2cViewerRole role = C2cViewerRole.fromWire(
      jsonString(data['viewer_role']),
    );
    final C2cParcelStatus status = C2cParcelStatus.fromWire(
      jsonString(data['status']),
    );
    final Map<dynamic, dynamic> parcel = _map(data['parcel']);
    final Map<dynamic, dynamic>? pricing = _mapOrNull(data['pricing']);
    final double? totalFee = pricing == null
        ? null
        : jsonDouble(pricing['total_fee']);
    final dynamic images = data['images'];

    return C2cParcelDetails(
      id: id,
      reference: jsonString(data['reference']) ?? '#$id',
      viewerRole: role,
      status: status,
      statusVersion: jsonInt(data['status_version']) ?? 0,
      item: C2cParcelItem(
        title: jsonString(parcel['title']),
        description: jsonString(parcel['description']),
        category: _category(jsonString(parcel['category'])),
        weightKg: jsonDouble(parcel['weight_kg']),
        isFragile: jsonBool(parcel['is_fragile']) ?? false,
        declaredValue: jsonDouble(parcel['declared_value']),
        pickupInstructions: jsonString(parcel['pickup_instructions']),
        deliveryInstructions: jsonString(parcel['delivery_instructions']),
      ),
      sender: _party(data['sender']),
      recipient: _party(data['recipient']),
      pricing: pricing == null || totalFee == null
          ? null
          : C2cPricing(
              totalFee: totalFee,
              currency: jsonString(pricing['currency']) ?? 'SAR',
              distanceKm: jsonDouble(pricing['distance_km']),
            ),
      paymentMethod: C2cPaymentMethod.fromWire(
        jsonString(data['payment_method']),
      ),
      imageCount: images is List ? images.length : 0,
      driver: _driver(data['driver']),
      timeline: _timeline(data['timeline']),
      actions: _actions(data['actions'], status: status, role: role),
    );
  }

  /// `GET /{id}/tracking`. Throws [ServerException] without a status.
  static C2cParcelTracking trackingFromJson(dynamic json) {
    final Map<dynamic, dynamic> data = _data(json);
    final String? status = jsonString(data['status']);
    if (status == null) throw const ServerException();
    final C2cParcelStatus parsed = C2cParcelStatus.fromWire(status);
    final Map<dynamic, dynamic>? location = _mapOrNull(data['driver_location']);
    final GeoPoint? driverPoint = location == null ? null : _point(location);

    return C2cParcelTracking(
      status: parsed,
      statusVersion: jsonInt(data['status_version']) ?? 0,
      isTerminal: jsonBool(data['is_terminal']) ?? parsed.isTerminal,
      timeline: _timeline(data['timeline']),
      pickup: _pointOf(data['pickup']),
      destination: _pointOf(data['destination']),
      driver: _driver(data['driver']),
      driverLocation: driverPoint == null
          ? null
          : C2cDriverLocation(
              point: driverPoint,
              heading: jsonDouble(location!['heading']),
              recordedAt: _date(location['recorded_at']),
            ),
      etaMinutes: jsonInt(data['eta_minutes']),
      pollingIntervalSeconds: jsonInt(data['polling_interval_seconds']),
    );
  }

  /// `POST /{id}/delivery-otp/request` → `{ data: { otp, expires_at,
  /// purpose } }`. A numeric `otp` keeps its leading zeros. Throws
  /// [ServerException] without a code.
  static C2cParcelOtp otpFromJson(dynamic json) {
    final Map<dynamic, dynamic> data = _data(json);
    final String? code = switch (data['otp']) {
      final int v => v.toString().padLeft(6, '0'),
      final dynamic v => jsonString(v),
    };
    if (code == null) throw const ServerException();
    return C2cParcelOtp(
      code: code,
      expiresAt: _date(data['expires_at']),
      purpose: (jsonString(data['purpose']) ?? '').contains('return')
          ? C2cOtpPurpose.returnToSender
          : C2cOtpPurpose.delivery,
    );
  }

  // --- Pieces ---

  static Map<dynamic, dynamic> _data(dynamic json) {
    if (json is Map && json['data'] is Map) return json['data'] as Map;
    if (json is Map) return json;
    throw const ServerException();
  }

  static Map<dynamic, dynamic> _map(dynamic json) =>
      json is Map ? json : const <dynamic, dynamic>{};

  static Map<dynamic, dynamic>? _mapOrNull(dynamic json) =>
      json is Map ? json : null;

  static DateTime? _date(dynamic value) =>
      DateTime.tryParse(jsonString(value) ?? '');

  static ParcelCategory? _category(String? value) {
    for (final ParcelCategory category in ParcelCategory.values) {
      if (category.name == value) return category;
    }
    return null;
  }

  static GeoPoint? _point(Map<dynamic, dynamic> json) {
    final double? latitude = jsonDouble(json['latitude']);
    final double? longitude = jsonDouble(json['longitude']);
    return latitude == null || longitude == null
        ? null
        : GeoPoint(latitude: latitude, longitude: longitude);
  }

  static GeoPoint? _pointOf(dynamic json) => json is Map ? _point(json) : null;

  static C2cParty _party(dynamic json) {
    final Map<dynamic, dynamic> party = _map(json);
    final Map<dynamic, dynamic> details = _map(party['details']);
    return C2cParty(
      name: jsonString(party['name']),
      phone: jsonString(party['phone']),
      address: jsonString(party['address']),
      location: _point(party),
      details: <String, String>{
        for (final MapEntry<dynamic, dynamic> entry in details.entries)
          if (entry.key is String && jsonString('${entry.value}') != null)
            entry.key as String: '${entry.value}'.trim(),
      },
    );
  }

  static C2cDriver? _driver(dynamic json) {
    if (json is! Map) return null;
    return C2cDriver(
      id: jsonInt(json['id']),
      name: jsonString(json['name']),
      imageUrl: jsonHttpUrl(json['image_url']),
      phone: jsonString(json['phone']),
    );
  }

  static List<C2cTimelineEntry> _timeline(dynamic json) {
    if (json is! List) return const <C2cTimelineEntry>[];
    return <C2cTimelineEntry>[
      for (final dynamic entry in json)
        if (entry is Map && jsonString(entry['status']) != null)
          C2cTimelineEntry(
            status: C2cParcelStatus.fromWire(jsonString(entry['status'])),
            statusVersion: jsonInt(entry['status_version']),
            occurredAt: _date(entry['occurred_at']),
          ),
    ];
  }

  /// The server's flags; without an `actions` block, what the API guide's
  /// rules allow for this status and role.
  static C2cParcelActions _actions(
    dynamic json, {
    required C2cParcelStatus status,
    required C2cViewerRole role,
  }) {
    final bool isSender = role == C2cViewerRole.sender;
    if (json is! Map) {
      return C2cParcelActions(
        canCancel: isSender && status.isBeforePickup,
        canRetryDispatch:
            isSender && status == C2cParcelStatus.assignmentFailed,
        canRequestDeliveryOtp: status.allowsDeliveryOtp,
        canRequestReturnOtp: isSender && status.allowsReturnOtp,
        canOpenSupportCase: !status.isTerminal,
      );
    }
    return C2cParcelActions(
      canCancel: jsonBool(json['can_cancel']) ?? false,
      canRetryDispatch: jsonBool(json['can_retry_dispatch']) ?? false,
      canRequestDeliveryOtp:
          jsonBool(json['can_request_delivery_otp']) ?? false,
      canRequestReturnOtp: jsonBool(json['can_request_return_otp']) ?? false,
      canOpenSupportCase: jsonBool(json['can_open_support_case']) ?? false,
    );
  }
}
