import '../../injection_container.dart';
import 'presentation/cubit/splash_cubit.dart';

/// Per-feature registration. See `home_injection.dart` for the convention.
///
/// [SplashCubit] is screen-scoped — provided at the splash route in
/// `AppRoutes`. Its repository is core (`ServiceLocator._injectAppConfig`).
Future<void> initSplashFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance.registerFactory<SplashCubit>(
    () => SplashCubit(
      repository: ServiceLocator.instance(),
      installedApp: ServiceLocator.instance(),
    ),
  );
}
