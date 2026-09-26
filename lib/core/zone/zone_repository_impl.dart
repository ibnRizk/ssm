import 'package:dartz/dartz.dart';

import '../api/safe_api_call.dart';
import '../error/exceptions.dart';
import '../error/failures.dart';
import '../services/local_storage/app_shared_preferences.dart';
import 'zone_remote_data_source.dart';
import 'zone_repository.dart';

class ZoneRepositoryImpl implements ZoneRepository {
  final ZoneRemoteDataSource remote;
  final AppSharedPreferences preferences;

  ZoneRepositoryImpl({required this.remote, required this.preferences});

  /// Screens load categories and stores concurrently; they share one
  /// resolution instead of each hitting the network.
  Future<Either<Failure, List<int>>>? _resolving;

  @override
  Future<Either<Failure, List<int>>> ensureZoneIds() {
    final List<int> saved = preferences.getZoneIds();
    if (saved.isNotEmpty) return Future.value(Right(saved));
    return _resolving ??= _resolve().whenComplete(() => _resolving = null);
  }

  @override
  Future<Either<Failure, Unit>> selectZoneIds(List<int> zoneIds) async {
    if (zoneIds.isEmpty) return const Right(unit);
    try {
      await preferences.saveZoneIds(zoneIds);
    } catch (_) {
      return const Left(CacheFailure());
    }
    return const Right(unit);
  }

  Future<Either<Failure, List<int>>> _resolve() => safeApiCall(() async {
    final int? zoneId =
        await remote.firstAddressZoneId() ?? await remote.firstServiceZoneId();
    if (zoneId == null) throw const _NoZoneException();
    final List<int> zoneIds = <int>[zoneId];
    // Fatal: the interceptor reads the zone from storage, so an unsaved zone
    // would send the caller's request without its `zoneId` header.
    try {
      await preferences.saveZoneIds(zoneIds);
    } catch (_) {
      throw const CacheException();
    }
    return zoneIds;
  });
}

class _NoZoneException extends AppException {
  @override
  String? get message => null;

  const _NoZoneException();

  @override
  Failure toFailure() => const ZoneUnavailableFailure();
}
