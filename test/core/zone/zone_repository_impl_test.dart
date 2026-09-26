import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:ssm/core/error/exceptions.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/core/services/local_storage/app_shared_preferences.dart';
import 'package:ssm/core/zone/zone_remote_data_source.dart';
import 'package:ssm/core/zone/zone_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeZoneRemote implements ZoneRemoteDataSource {
  int? addressZoneId;
  int? serviceZoneId;
  Object? error;

  /// When set, [firstAddressZoneId] waits on it — lets a test hold the
  /// resolution open to issue a concurrent call.
  Completer<void>? gate;

  int addressCalls = 0;
  int serviceCalls = 0;

  @override
  Future<int?> firstAddressZoneId() async {
    addressCalls++;
    await gate?.future;
    if (error case final Object e) throw e;
    return addressZoneId;
  }

  @override
  Future<int?> firstServiceZoneId() async {
    serviceCalls++;
    return serviceZoneId;
  }
}

/// Storage that refuses to save a zone.
class _FailingPreferences extends AppSharedPreferencesImpl {
  _FailingPreferences({required super.instance});

  @override
  Future<bool> saveZoneIds(List<int> ids) async => throw Exception('disk full');
}

void main() {
  late _FakeZoneRemote remote;
  late AppSharedPreferences preferences;
  late ZoneRepositoryImpl repository;

  Future<void> setUpWith(Map<String, Object> stored) async {
    SharedPreferences.setMockInitialValues(stored);
    preferences = AppSharedPreferencesImpl(
      instance: await SharedPreferences.getInstance(),
    );
    remote = _FakeZoneRemote();
    repository = ZoneRepositoryImpl(remote: remote, preferences: preferences);
  }

  group('ensureZoneIds', () {
    test('returns the saved zone without calling the network', () async {
      await setUpWith(<String, Object>{
        'zoneIds': <String>['3'],
      });

      final Either<Failure, List<int>> result = await repository
          .ensureZoneIds();

      expect(result.getOrElse(() => <int>[]), <int>[3]);
      expect(remote.addressCalls, 0);
    });

    test('uses the zone of a saved address and stores it', () async {
      await setUpWith(<String, Object>{});
      remote
        ..addressZoneId = 2
        ..serviceZoneId = 9;

      final Either<Failure, List<int>> result = await repository
          .ensureZoneIds();

      expect(result.getOrElse(() => <int>[]), <int>[2]);
      expect(preferences.getZoneIds(), <int>[2]);
      expect(remote.serviceCalls, 0);
    });

    test('falls back to the first service zone without an address', () async {
      await setUpWith(<String, Object>{});
      remote.serviceZoneId = 1;

      final Either<Failure, List<int>> result = await repository
          .ensureZoneIds();

      expect(result.getOrElse(() => <int>[]), <int>[1]);
      expect(preferences.getZoneIds(), <int>[1]);
    });

    test('is a ZoneUnavailableFailure when there is no zone at all', () async {
      await setUpWith(<String, Object>{});

      final Either<Failure, List<int>> result = await repository
          .ensureZoneIds();

      expect(result, const Left<Failure, List<int>>(ZoneUnavailableFailure()));
      expect(preferences.getZoneIds(), isEmpty);
    });

    test('maps a network error to a failure and stores nothing', () async {
      await setUpWith(<String, Object>{});
      remote.error = const InternetConnectionException(message: 'offline');

      final Either<Failure, List<int>> result = await repository
          .ensureZoneIds();

      expect(
        result,
        const Left<Failure, List<int>>(NetworkFailure(message: 'offline')),
      );
      expect(preferences.getZoneIds(), isEmpty);
    });

    test('concurrent calls share one resolution', () async {
      await setUpWith(<String, Object>{});
      remote
        ..addressZoneId = 4
        ..gate = Completer<void>();

      final Future<Either<Failure, List<int>>> first = repository
          .ensureZoneIds();
      final Future<Either<Failure, List<int>>> second = repository
          .ensureZoneIds();
      remote.gate!.complete();

      expect((await first).getOrElse(() => <int>[]), <int>[4]);
      expect((await second).getOrElse(() => <int>[]), <int>[4]);
      expect(remote.addressCalls, 1);
    });
  });

  group('selectZoneIds', () {
    test('stores the new zone', () async {
      await setUpWith(<String, Object>{
        'zoneIds': <String>['1'],
      });

      await repository.selectZoneIds(<int>[5]);

      expect(preferences.getZoneIds(), <int>[5]);
    });

    test('ignores an empty list, keeping the current zone', () async {
      await setUpWith(<String, Object>{
        'zoneIds': <String>['1'],
      });

      await repository.selectZoneIds(<int>[]);

      expect(preferences.getZoneIds(), <int>[1]);
    });
  });

  test('a zone that cannot be stored is a CacheFailure', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    remote = _FakeZoneRemote()..addressZoneId = 2;
    repository = ZoneRepositoryImpl(
      remote: remote,
      preferences: _FailingPreferences(
        instance: await SharedPreferences.getInstance(),
      ),
    );

    final Either<Failure, List<int>> result = await repository.ensureZoneIds();

    expect(result, const Left<Failure, List<int>>(CacheFailure()));
  });
}
