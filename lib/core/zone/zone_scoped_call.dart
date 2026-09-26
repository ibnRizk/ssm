import 'package:dartz/dartz.dart';

import '../api/safe_api_call.dart';
import '../error/failures.dart';
import 'zone_repository.dart';

extension ZoneScopedCall on ZoneRepository {
  /// Runs [call] — which needs the zone headers — once a zone is stored
  /// (and so sent by the interceptor). Without one the backend refuses the
  /// call, so the zone's failure is returned instead of making it.
  Future<Either<Failure, T>> inZone<T>(Future<T> Function() call) async {
    final Either<Failure, List<int>> zone = await ensureZoneIds();
    return zone.fold(
      (Failure failure) async => Left<Failure, T>(failure),
      (_) => safeApiCall(call),
    );
  }
}
