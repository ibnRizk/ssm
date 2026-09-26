import '../../injection_container.dart';
import 'data/datasources/loyalty_remote_data_source.dart';
import 'data/repos/loyalty_repository_impl.dart';
import 'domain/repos/loyalty_repository.dart';

/// Per-feature registration. See `home_injection.dart` for the convention.
Future<void> initLoyaltyFeatureInjection() async {
  /// Repository
  ServiceLocator.instance.registerLazySingleton<LoyaltyRepository>(
    () => LoyaltyRepositoryImpl(remote: ServiceLocator.instance()),
  );

  /// DataSource
  ServiceLocator.instance.registerLazySingleton<LoyaltyRemoteDataSource>(
    () => LoyaltyRemoteDataSourceImpl(consumer: ServiceLocator.instance()),
  );
}
