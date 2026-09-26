import '../../injection_container.dart';
import 'data/datasources/cart_remote_data_source.dart';
import 'data/repos/cart_repository_impl.dart';
import 'domain/repos/cart_repository.dart';
import 'presentation/cubit/cart_cubit.dart';

/// Per-feature registration. See `home_injection.dart` for the convention.
///
/// [CartCubit] is screen-scoped: the store-details route creates it and
/// hands the same instance to Cart and Checkout through `extra`.
Future<void> initCartFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance.registerFactory<CartCubit>(
    () => CartCubit(repository: ServiceLocator.instance()),
  );

  /// Repository
  ServiceLocator.instance.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(
      remote: ServiceLocator.instance(),
      zoneRepository: ServiceLocator.instance(),
    ),
  );

  /// DataSource
  ServiceLocator.instance.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(consumer: ServiceLocator.instance()),
  );
}
