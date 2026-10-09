import '../../injection_container.dart';
import 'data/datasources/c2c_parcels_remote_data_source.dart';
import 'data/datasources/parcels_remote_data_source.dart';
import 'data/repos/c2c_parcels_repository_impl.dart';
import 'data/repos/parcels_repository_impl.dart';
import 'domain/repos/c2c_parcels_repository.dart';
import 'domain/repos/parcels_repository.dart';
import 'presentation/cubit/parcels_cubit.dart';
import 'presentation/cubit/send_parcel_cubit.dart';

/// Per-feature registration. See `home_injection.dart` for the convention.
///
/// [ParcelsCubit] and [SendParcelCubit] are screen-scoped — provided at
/// their routes in `AppRoutes`. The device location comes from core.
Future<void> initParcelsFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance.registerFactory<ParcelsCubit>(
    () => ParcelsCubit(
      parcelsRepository: ServiceLocator.instance(),
      locationRepository: ServiceLocator.instance(),
    ),
  );
  ServiceLocator.instance.registerFactory<SendParcelCubit>(
    () => SendParcelCubit(
      repository: ServiceLocator.instance(),
      locationRepository: ServiceLocator.instance(),
    ),
  );

  /// Repository
  ServiceLocator.instance.registerLazySingleton<ParcelsRepository>(
    () => ParcelsRepositoryImpl(remote: ServiceLocator.instance()),
  );
  ServiceLocator.instance.registerLazySingleton<C2cParcelsRepository>(
    () => C2cParcelsRepositoryImpl(remote: ServiceLocator.instance()),
  );

  /// DataSource
  ServiceLocator.instance.registerLazySingleton<ParcelsRemoteDataSource>(
    () => ParcelsRemoteDataSourceImpl(consumer: ServiceLocator.instance()),
  );
  ServiceLocator.instance.registerLazySingleton<C2cParcelsRemoteDataSource>(
    () => C2cParcelsRemoteDataSourceImpl(consumer: ServiceLocator.instance()),
  );
}
