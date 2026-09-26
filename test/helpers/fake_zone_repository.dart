import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/core/zone/zone_repository.dart';

/// For cubit tests: a fixed current zone, and [change] to announce a new one.
class FakeZoneRepository implements ZoneRepository {
  final StreamController<List<int>> _changes =
      StreamController<List<int>>.broadcast(sync: true);

  @override
  List<int> currentZoneIds = const <int>[8];

  /// Switches to [zoneIds] and announces it, like a real zone switch.
  void change(List<int> zoneIds) {
    currentZoneIds = zoneIds;
    _changes.add(zoneIds);
  }

  @override
  Stream<List<int>> get zoneChanges => _changes.stream;

  @override
  Future<Either<Failure, List<int>>> ensureZoneIds() async =>
      Right<Failure, List<int>>(currentZoneIds);

  @override
  Future<Either<Failure, Unit>> selectZoneIds(List<int> zoneIds) =>
      throw UnimplementedError();
}
