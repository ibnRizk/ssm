import '../../injection_container.dart';
import 'data/datasources/catalog_remote_data_source.dart';
import 'data/repos/catalog_repository_impl.dart';
import 'domain/repos/catalog_repository.dart';

/// Per-feature registration. See `home_injection.dart` for the convention.
///
/// Data and domain only — the Home and Restaurants features own the screens
/// (and cubits) that browse the catalog.
Future<void> initCatalogFeatureInjection() async {
  /// Repository
  ServiceLocator.instance.registerLazySingleton<CatalogRepository>(
    () => CatalogRepositoryImpl(
      remote: ServiceLocator.instance(),
      zoneRepository: ServiceLocator.instance(),
    ),
  );

  /// DataSource
  ServiceLocator.instance.registerLazySingleton<CatalogRemoteDataSource>(
    () => CatalogRemoteDataSourceImpl(consumer: ServiceLocator.instance()),
  );
}
