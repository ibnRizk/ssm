import 'dart:async';

import 'package:dartz/dartz.dart';

import '../api/safe_api_call.dart';
import '../error/exceptions.dart';
import '../error/failures.dart';
import '../location/device_location_data_source.dart';
import '../location/geo_point.dart';
import '../services/local_storage/app_shared_preferences.dart';
import 'zone_remote_data_source.dart';
import 'zone_repository.dart';

class ZoneRepositoryImpl implements ZoneRepository {
  final ZoneRemoteDataSource remote;
  final DeviceLocationDataSource location;
  final AppSharedPreferences preferences;

  ZoneRepositoryImpl({
    required this.remote,
    required this.location,
    required this.preferences,
  });

  final StreamController<List<int>> _changes =
      StreamController<List<int>>.broadcast();

  /// Whether this launch has resolved the zone against the backend. Until
  /// then a saved zone is only a guess — it may be from an old address or
  /// a zone the stores have since moved out of.
  bool _resolved = false;

  /// Screens load categories and stores concurrently; they share one
  /// resolution instead of each hitting the network.
  Future<Either<Failure, List<int>>>? _resolving;

  @override
  List<int> get currentZoneIds => preferences.getZoneIds();

  @override
  Stream<List<int>> get zoneChanges => _changes.stream;

  @override
  Future<Either<Failure, List<int>>> ensureZoneIds() {
    final List<int> saved = preferences.getZoneIds();
    if (_resolved && saved.isNotEmpty) return Future.value(Right(saved));
    return _resolving ??= _resolve(saved).whenComplete(() => _resolving = null);
  }

  @override
  Future<Either<Failure, Unit>> selectZoneIds(List<int> zoneIds) async {
    if (zoneIds.isEmpty) return const Right(unit);
    try {
      await _save(zoneIds);
    } catch (_) {
      return const Left(CacheFailure());
    }
    return const Right(unit);
  }

  Future<Either<Failure, List<int>>> _resolve(List<int> saved) async {
    final Either<Failure, List<int>> result = await safeApiCall(
      () => _pick(saved),
    );
    return result.fold((Failure failure) {
      // Offline or a server error: keep browsing the saved zone, and try
      // resolving again on the next call.
      final bool keepSaved =
          saved.isNotEmpty &&
          failure is! ZoneUnavailableFailure &&
          failure is! CacheFailure;
      return keepSaved ? Right(saved) : Left(failure);
    }, (List<int> zoneIds) => Right(zoneIds));
  }

  Future<List<int>> _pick(List<int> saved) async {
    final List<int> addressZones = await remote.addressZoneIds();
    final List<int> zoneIds;
    if (addressZones.isNotEmpty) {
      // A zone picked from one of the addresses (e.g. at checkout) stays.
      zoneIds = saved.isNotEmpty && saved.every(addressZones.contains)
          ? saved
          : <int>[addressZones.first];
    } else {
      zoneIds =
          await _zoneHere() ??
          (saved.isNotEmpty ? saved : <int>[await _firstServiceZone()]);
    }
    // Fatal: the interceptor reads the zone from storage, so an unsaved zone
    // would send the caller's request without its `zoneId` header.
    try {
      await _save(zoneIds);
    } catch (_) {
      throw const CacheException();
    }
    _resolved = true;
    return zoneIds;
  }

  /// The zone at the device's location; null when the device can't tell
  /// where it is. Throws [_NoZoneException] when it's outside every zone.
  Future<List<int>?> _zoneHere() async {
    final GeoPoint point;
    try {
      point = await location.getCurrentLocation();
    } on LocationException {
      return null;
    }
    try {
      return await remote.zoneIdsAt(point);
    } on NotFoundException catch (e) {
      throw _NoZoneException(message: e.message);
    }
  }

  Future<int> _firstServiceZone() async =>
      await remote.firstServiceZoneId() ?? (throw const _NoZoneException());

  /// Stores [zoneIds], announcing it when it replaces a different zone. A
  /// first zone isn't announced: nothing could load before it existed.
  Future<void> _save(List<int> zoneIds) async {
    final List<int> before = preferences.getZoneIds();
    await preferences.saveZoneIds(zoneIds);
    if (before.isNotEmpty && before.join(',') != zoneIds.join(',')) {
      _changes.add(List<int>.unmodifiable(zoneIds));
    }
  }
}

class _NoZoneException extends AppException {
  @override
  final String? message;

  const _NoZoneException({this.message});

  @override
  Failure toFailure() => ZoneUnavailableFailure(message: message);
}
