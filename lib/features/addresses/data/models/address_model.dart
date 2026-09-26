import '../../../../core/api/json_readers.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/address.dart';

/// One entry of `GET /customer/address/list` → `{ "addresses": [...] }`.
class AddressModel extends Address {
  const AddressModel({
    required super.id,
    required super.type,
    required super.contactPersonName,
    required super.contactPersonNumber,
    required super.address,
    super.location,
    super.zoneId,
  });

  /// Null for an entry without an id or address text — it can't be shown
  /// or deleted, so the list skips it rather than failing as a whole.
  static AddressModel? tryFromJson(dynamic json) {
    if (json is! Map) return null;
    final int? id = jsonInt(json['id']);
    final String? address = jsonString(json['address']);
    if (id == null || address == null) return null;
    final double? latitude = jsonDouble(json['latitude']);
    final double? longitude = jsonDouble(json['longitude']);
    return AddressModel(
      id: id,
      type: addressTypeFromWire(jsonString(json['address_type'])),
      contactPersonName: jsonString(json['contact_person_name']) ?? '',
      contactPersonNumber: jsonString(json['contact_person_number']) ?? '',
      address: address,
      location: latitude == null || longitude == null
          ? null
          : GeoPoint(latitude: latitude, longitude: longitude),
      zoneId: jsonInt(json['zone_id']),
    );
  }

  /// Throws [ServerException] when the body has no `addresses` list.
  static List<AddressModel> listFromJson(dynamic json) {
    final dynamic addresses = json is Map ? json['addresses'] : null;
    if (addresses is! List) throw const ServerException();
    return addresses
        .map(AddressModel.tryFromJson)
        .whereType<AddressModel>()
        .toList(growable: false);
  }

  /// Unknown values (the legacy backend also has `others`, `workplace`, …)
  /// read as [AddressType.other].
  static AddressType addressTypeFromWire(String? value) =>
      switch (value?.toLowerCase()) {
        'home' => AddressType.home,
        'office' => AddressType.office,
        _ => AddressType.other,
      };

  static String addressTypeToWire(AddressType type) => switch (type) {
    AddressType.home => 'home',
    AddressType.office => 'office',
    AddressType.other => 'other',
  };
}
