import '../../injection_container.dart';
import 'presentation/cubit/home_cubit.dart';

/// Per-feature registration. Copy this file's shape for every new feature and
/// call it from `ServiceLocator.init()`.
///
/// Convention: cubits are `registerFactory` (fresh instance per screen), while
/// repositories and data sources are `registerLazySingleton` (stateless,
/// shared).
///
/// [HomeCubit] is screen-scoped — provided at the home route in `AppRoutes`.
/// Its repositories are registered by the account and catalog features.
Future<void> initHomeFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance.registerFactory<HomeCubit>(
    () => HomeCubit(
      accountRepository: ServiceLocator.instance(),
      catalogRepository: ServiceLocator.instance(),
    ),
  );
}
