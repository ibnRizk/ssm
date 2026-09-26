import '../api/api_endpoints.dart';
import '../api/dio_consumer.dart';
import '../api/json_readers.dart';
import '../error/exceptions.dart';

/// The two places the backend exposes a zone id to a customer. Only ids are
/// read — the addresses and subscriptions features own the full models.
abstract class ZoneRemoteDataSource {
  /// Zone of the first saved address that has one; null when there's none.
  Future<int?> firstAddressZoneId();

  /// First zone of `GET /zone/list`; null when the backend has no zones.
  Future<int?> firstServiceZoneId();
}

class ZoneRemoteDataSourceImpl implements ZoneRemoteDataSource {
  final DioConsumer consumer;

  const ZoneRemoteDataSourceImpl({required this.consumer});

  /// `{ "addresses": [ { "zone_id": 1, ... } ] }`. Throws [ServerException]
  /// when the body has no `addresses` list.
  @override
  Future<int?> firstAddressZoneId() async {
    final dynamic json = await consumer.get(ApiEndpoints.addressList);
    final dynamic addresses = json is Map ? json['addresses'] : null;
    if (addresses is! List) throw const ServerException();
    for (final dynamic address in addresses) {
      final int? zoneId = address is Map ? jsonInt(address['zone_id']) : null;
      if (zoneId != null) return zoneId;
    }
    return null;
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
