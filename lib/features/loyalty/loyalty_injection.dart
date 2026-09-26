import '../../injection_container.dart';
import 'data/datasources/loyalty_remote_data_source.dart';
import 'data/repos/loyalty_repository_impl.dart';
import 'domain/repos/loyalty_repository.dart';
import 'presentation/cubit/loyalty_cubit.dart';

/// Per-feature registration. See `home_injection.dart` for the convention.
///
/// [LoyaltyCubit] is screen-scoped — provided at the loyalty route in
/// `AppRoutes`.
Future<void> initLoyaltyFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance.registerFactory<LoyaltyCubit>(
    () => LoyaltyCubit(repository: ServiceLocator.instance()),
  );

  /// Repository
  ServiceLocator.instance.registerLazySingleton<LoyaltyRepository>(
    () => LoyaltyRepositoryImpl(remote: ServiceLocator.instance()),
  );

  /// DataSource
  ServiceLocator.instance.registerLazySingleton<LoyaltyRemoteDataSource>(
    () => LoyaltyRemoteDataSourceImpl(consumer: ServiceLocator.instance()),
  );
}
