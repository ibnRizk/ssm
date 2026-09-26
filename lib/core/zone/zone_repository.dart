import 'package:dartz/dartz.dart';

import '../error/failures.dart';

/// The backend module every catalog, cart and order call is scoped to (sent
/// as the `moduleId` header). The customer app has a single module.
const int defaultModuleId = 1;

/// Owns the customer's current delivery zone — the `zoneId` header that
/// catalog, cart and order calls need. Lives in `core` because every
/// shopping feature depends on it.
abstract class ZoneRepository {
  /// The zone to scope requests to, resolved and persisted on first use:
  /// the saved zone, else the zone of the customer's first saved address,
  /// else the first service zone. [ZoneUnavailableFailure] when the backend
  /// has no zone at all.
  Future<Either<Failure, List<int>>> ensureZoneIds();

  /// Switches the zone, e.g. when the customer picks another delivery
  /// address. An empty list is ignored — it would make catalog calls fail.
  Future<Either<Failure, Unit>> selectZoneIds(List<int> zoneIds);
}
