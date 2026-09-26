import '../../injection_container.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/repos/auth_repository_impl.dart';
import 'domain/repos/auth_repository.dart';
import 'presentation/cubit/auth_cubit.dart';

/// Per-feature registration. See `home_injection.dart` for the convention.
///
/// [AuthCubit] is screen-scoped, so it's provided at the Login/Register
/// routes in `AppRoutes` rather than app-wide.
Future<void> initAuthFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance.registerFactory<AuthCubit>(
    () => AuthCubit(repository: ServiceLocator.instance()),
  );

  /// Repository
  ServiceLocator.instance.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remote: ServiceLocator.instance(),
      secureStorage: ServiceLocator.instance(),
      sharedPreferences: ServiceLocator.instance(),
    ),
  );

  /// DataSource
  ServiceLocator.instance.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(consumer: ServiceLocator.instance()),
  );
}
