import '../../injection_container.dart';
import 'data/datasources/address_remote_data_source.dart';
import 'data/repos/address_repository_impl.dart';
import 'domain/repos/address_repository.dart';
import 'presentation/cubit/add_address_cubit.dart';
import 'presentation/cubit/addresses_cubit.dart';

/// Per-feature registration. See `home_injection.dart` for the convention.
///
/// Both cubits are screen-scoped — provided at the addresses routes in
/// `AppRoutes`. The device location comes from core (see
/// `ServiceLocator._injectLocation`).
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

  /// Repository
  ServiceLocator.instance.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(remote: ServiceLocator.instance()),
  );

  /// DataSource
  ServiceLocator.instance.registerLazySingleton<AddressRemoteDataSource>(
    () => AddressRemoteDataSourceImpl(consumer: ServiceLocator.instance()),
  );
}
