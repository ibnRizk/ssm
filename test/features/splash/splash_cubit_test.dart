import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/app_config/app_config.dart';
import 'package:ssm/core/app_config/app_config_repository.dart';
import 'package:ssm/core/app_config/app_version.dart';
import 'package:ssm/core/app_config/installed_app.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:ssm/features/splash/presentation/cubit/splash_state.dart';

const InstalledApp _installed = InstalledApp(
  version: AppVersion(<int>[1, 0, 0]),
  platform: AppPlatform.android,
);

const String _storeUrl = 'https://play.google.com/store/apps/details?id=x';

class _FakeAppConfigRepository implements AppConfigRepository {
  Either<Failure, AppConfig> answer;
  int calls = 0;

  _FakeAppConfigRepository(this.answer);

  @override
  Future<Either<Failure, AppConfig>> getConfig() async {
    calls++;
    return answer;
  }
}

AppConfig _config({bool maintenance = false, List<int> minimum = const [0]}) =>
    AppConfig(
      maintenanceMode: maintenance,
      minimumAndroidVersion: AppVersion(minimum),
      androidStoreUrl: _storeUrl,
    );

void main() {
  late _FakeAppConfigRepository repository;
  late SplashCubit cubit;

  void build(Either<Failure, AppConfig> answer) {
    repository = _FakeAppConfigRepository(answer);
    cubit = SplashCubit(repository: repository, installedApp: _installed);
  }

  tearDown(() => cubit.close());

  test('is ready when the build is current and the backend is up', () async {
    build(Right(_config()));

    await cubit.start();

    expect(cubit.state, const SplashReady());
  });

  test('requires an update when the build is below the minimum', () async {
    build(Right(_config(minimum: <int>[1, 1, 0])));

    await cubit.start();

    expect(cubit.state, const SplashUpdateRequired(storeUrl: _storeUrl));
  });

  test('shows maintenance when the backend is in maintenance', () async {
    build(Right(_config(maintenance: true)));

    await cubit.start();

    expect(cubit.state, const SplashMaintenance());
  });

  test('asks for the update before reporting maintenance', () async {
    build(Right(_config(maintenance: true, minimum: <int>[2])));

    await cubit.start();

    expect(cubit.state, isA<SplashUpdateRequired>());
  });

  test('lets the customer in when the config cannot be fetched', () async {
    build(const Left(NetworkFailure()));

    await cubit.start();

    expect(cubit.state, const SplashReady());
  });

  test('a retry after maintenance re-checks and lets them in', () async {
    build(Right(_config(maintenance: true)));
    await cubit.start();
    repository.answer = Right(_config());

    final Future<void> expectation = expectLater(
      cubit.stream,
      emitsInOrder(<SplashState>[const SplashLoading(), const SplashReady()]),
    );
    await cubit.start();
    await expectation;

    expect(repository.calls, 2);
  });
}
