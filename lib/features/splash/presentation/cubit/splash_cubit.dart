import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app_config/app_config.dart';
import '../../../../core/app_config/app_config_repository.dart';
import '../../../../core/app_config/installed_app.dart';
import '../../../../core/error/failures.dart';
import 'splash_state.dart';

/// Screen-scoped (one instance per Splash route). Gates entry into the app
/// on the backend's config: force update first — it's the one the customer
/// can act on — then maintenance mode.
class SplashCubit extends Cubit<SplashState> {
  final AppConfigRepository repository;
  final InstalledApp installedApp;

  SplashCubit({required this.repository, required this.installedApp})
    : super(const SplashLoading());

  /// Waits at least [minimumDuration] so the boot animation can finish.
  Future<void> start({Duration minimumDuration = Duration.zero}) async {
    emit(const SplashLoading());
    final (Either<Failure, AppConfig> result, _) = await (
      repository.getConfig(),
      Future<void>.delayed(minimumDuration),
    ).wait;
    if (isClosed) return;
    emit(
      result.fold(
        // Fail open: the gate is best-effort, and a config outage or a bad
        // connection must not lock every customer out. The next launch
        // checks again; the screens behind it report their own errors.
        (_) => const SplashReady(),
        (AppConfig config) {
          if (config.requiresUpdate(installedApp)) {
            return SplashUpdateRequired(
              storeUrl: config.storeUrlFor(installedApp.platform),
            );
          }
          if (config.maintenanceMode) return const SplashMaintenance();
          return const SplashReady();
        },
      ),
    );
  }
}
