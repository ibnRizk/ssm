import '../../../../core/api/json_readers.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/delivery_zone.dart';

/// `GET /zone/list` → a bare JSON array of zones.
class DeliveryZoneModel extends DeliveryZone {
  const DeliveryZoneModel({required super.id, required super.name});

  /// Null for an entry without an id or any name — it can't be selected.
  static DeliveryZoneModel? tryFromJson(dynamic json) {
    if (json is! Map) return null;
    final int? id = jsonInt(json['id']);
    final String? name =
        jsonString(json['display_name']) ?? jsonString(json['name']);
    if (id == null || name == null) return null;
    return DeliveryZoneModel(id: id, name: name);
  }

  /// Throws [ServerException] when the body isn't a list.
  static List<DeliveryZoneModel> listFromJson(dynamic json) {
    if (json is! List) throw const ServerException();
    return json
        .map(DeliveryZoneModel.tryFromJson)
        .whereType<DeliveryZoneModel>()
        .toList(growable: false);
  }
}
