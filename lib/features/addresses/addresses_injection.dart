import '../../injection_container.dart';
import 'data/datasources/address_remote_data_source.dart';
import 'data/datasources/device_location_data_source.dart';
import 'data/repos/address_repository_impl.dart';
import 'data/repos/location_repository_impl.dart';
import 'domain/repos/address_repository.dart';
import 'domain/repos/location_repository.dart';
import 'presentation/cubit/add_address_cubit.dart';
import 'presentation/cubit/addresses_cubit.dart';

/// Per-feature registration. See `home_injection.dart` for the convention.
///
/// Both cubits are screen-scoped — provided at the addresses routes in
/// `AppRoutes`.
Future<void> initAddressesFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance.registerFactory<AddressesCubit>(
    () => AddressesCubit(repository: ServiceLocator.instance()),
  );
  ServiceLocator.instance.registerFactory<AddAddressCubit>(
    () => AddAddressCubit(
      addressRepository: ServiceLocator.instance(),
      locationRepository: ServiceLocator.instance(),
    ),
  );

  /// Repositories
  ServiceLocator.instance.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(remote: ServiceLocator.instance()),
  );
  ServiceLocator.instance.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(device: ServiceLocator.instance()),
  );

  /// DataSources
  ServiceLocator.instance.registerLazySingleton<AddressRemoteDataSource>(
    () => AddressRemoteDataSourceImpl(consumer: ServiceLocator.instance()),
  );
  ServiceLocator.instance.registerLazySingleton<DeviceLocationDataSource>(
    () => const DeviceLocationDataSourceImpl(),
  );
}
