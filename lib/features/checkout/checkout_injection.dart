import '../../injection_container.dart';
import 'data/datasources/checkout_remote_data_source.dart';
import 'data/repos/checkout_repository_impl.dart';
import 'domain/repos/checkout_repository.dart';
import 'presentation/cubit/checkout_cubit.dart';

/// Per-feature registration. See `home_injection.dart` for the convention.
///
/// [CheckoutCubit] is screen-scoped — provided at the checkout route in
/// `AppRoutes`, next to the `CartCubit` the Cart screen hands over.
Future<void> initCheckoutFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance.registerFactory<CheckoutCubit>(
    () => CheckoutCubit(
      checkoutRepository: ServiceLocator.instance(),
      addressRepository: ServiceLocator.instance(),
      catalogRepository: ServiceLocator.instance(),
    ),
  );

  /// Repository
  ServiceLocator.instance.registerLazySingleton<CheckoutRepository>(
    () => CheckoutRepositoryImpl(
      remote: ServiceLocator.instance(),
      zoneRepository: ServiceLocator.instance(),
    ),
  );

  /// DataSource
  ServiceLocator.instance.registerLazySingleton<CheckoutRemoteDataSource>(
    () => CheckoutRemoteDataSourceImpl(consumer: ServiceLocator.instance()),
  );
}
