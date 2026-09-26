import '../api/api_endpoints.dart';
import '../api/dio_consumer.dart';
import '../api/json_readers.dart';
import '../error/exceptions.dart';
import '../location/geo_point.dart';

/// The places the backend exposes a zone id to a customer. Only ids are
/// read — the addresses and subscriptions features own the full models.
abstract class ZoneRemoteDataSource {
  /// Zones of the saved addresses, in the backend's order, without
  /// duplicates; empty when there's none.
  Future<List<int>> addressZoneIds();

  /// The zones covering [point]. Throws [NotFoundException] when it's
  /// outside every zone.
  Future<List<int>> zoneIdsAt(GeoPoint point);

  /// First zone of `GET /zone/list`; null when the backend has no zones.
  Future<int?> firstServiceZoneId();
}

class ZoneRemoteDataSourceImpl implements ZoneRemoteDataSource {
  final DioConsumer consumer;

  const ZoneRemoteDataSourceImpl({required this.consumer});

  /// `{ "addresses": [ { "zone_id": 1, ... } ] }`. Throws [ServerException]
  /// when the body has no `addresses` list.
  @override
  Future<List<int>> addressZoneIds() async {
    final dynamic json = await consumer.get(ApiEndpoints.addressList);
    final dynamic addresses = json is Map ? json['addresses'] : null;
    if (addresses is! List) throw const ServerException();
    return addresses
        .map((dynamic a) => a is Map ? jsonInt(a['zone_id']) : null)
        .whereType<int>()
        .toSet()
        .toList(growable: false);
  }

  /// `{ "zone_id": "[8]", "zone_data": [...] }` — the ids come JSON-encoded
  /// in a string. Throws [ServerException] when there's no usable id.
  @override
  Future<List<int>> zoneIdsAt(GeoPoint point) async {
    final dynamic json = await consumer.get(
      ApiEndpoints.zoneAt,
      queryParameters: <String, dynamic>{
        'lat': point.latitude,
        'lng': point.longitude,
      },
    );
    final dynamic ids = jsonDecodedIfString(
      json is Map ? json['zone_id'] : null,
    );
    final List<int> zoneIds = ids is List
        ? ids.map(jsonInt).whereType<int>().toList(growable: false)
        : const <int>[];
    if (zoneIds.isEmpty) throw const ServerException();
    return zoneIds;
  }

  /// A bare array of zones. Throws [ServerException] when it isn't a list.
  @override
  Future<int?> firstServiceZoneId() async {
    final dynamic zones = await consumer.get(ApiEndpoints.zoneList);
    if (zones is! List) throw const ServerException();
    for (final dynamic zone in zones) {
      final int? id = zone is Map ? jsonInt(zone['id']) : null;
      if (id != null) return id;
    }
    return null;
  }
}
