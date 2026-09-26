import 'package:dartz/dartz.dart';

import '../error/failures.dart';

/// The backend module every catalog, cart and order call is scoped to (sent
/// as the `moduleId` header). The customer app has a single module.
const int defaultModuleId = 1;

/// Owns the customer's current delivery zone — the `zoneId` header that
/// catalog, cart and order calls need. Lives in `core` because every
/// shopping feature depends on it.
abstract class ZoneRepository {
  /// The zone to scope requests to. The first call of each launch resolves
  /// it again, so a saved zone the customer no longer matches can't stick:
  /// the saved zone when it's one of the customer's address zones, else the
  /// first address's zone, else the zone at the device's location, else
  /// (location unknown) the saved zone or the first service zone.
  /// [ZoneUnavailableFailure] when the device is outside every zone or the
  /// backend has none. Offline, a saved zone is kept.
  Future<Either<Failure, List<int>>> ensureZoneIds();

  /// Switches the zone, e.g. when the customer picks another delivery
  /// address. An empty list is ignored — it would make catalog calls fail.
  Future<Either<Failure, Unit>> selectZoneIds(List<int> zoneIds);

  /// The zone requests are sent with right now; empty until one is resolved.
  List<int> get currentZoneIds;

  /// Emits the new zone whenever it replaces a different one, so screens
  /// showing the old zone's catalog can reload.
  Stream<List<int>> get zoneChanges;
}
