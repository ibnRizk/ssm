import '../../injection_container.dart';
import 'data/datasources/parcels_remote_data_source.dart';
import 'data/repos/parcels_repository_impl.dart';
import 'domain/repos/parcels_repository.dart';
import 'presentation/cubit/parcels_cubit.dart';

/// Per-feature registration. See `home_injection.dart` for the convention.
///
/// [ParcelsCubit] is screen-scoped — provided at the parcels route in
/// `AppRoutes`. The device location comes from core.
Future<void> initParcelsFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance.registerFactory<ParcelsCubit>(
    () => ParcelsCubit(
      parcelsRepository: ServiceLocator.instance(),
      locationRepository: ServiceLocator.instance(),
    ),
  );

  /// Repository
  ServiceLocator.instance.registerLazySingleton<ParcelsRepository>(
    () => ParcelsRepositoryImpl(remote: ServiceLocator.instance()),
  );

  /// DataSource
  ServiceLocator.instance.registerLazySingleton<ParcelsRemoteDataSource>(
    () => ParcelsRemoteDataSourceImpl(consumer: ServiceLocator.instance()),
  );
}
