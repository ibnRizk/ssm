import '../../injection_container.dart';
import 'data/datasources/order_tracking_remote_data_source.dart';
import 'data/repos/order_tracking_repository_impl.dart';
import 'domain/repos/order_tracking_repository.dart';
import 'presentation/cubit/order_tracking_cubit.dart';

/// Per-feature registration. See `home_injection.dart` for the convention.
///
/// [OrderTrackingCubit] is screen-scoped and takes the order id — see the
/// tracking route in `AppRoutes`.
Future<void> initOrderTrackingFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance.registerFactoryParam<OrderTrackingCubit, int, void>(
    (int orderId, _) => OrderTrackingCubit(
      orderId: orderId,
      repository: ServiceLocator.instance(),
      realtime: ServiceLocator.instance(),
    ),
  );

  /// Repository
  ServiceLocator.instance.registerLazySingleton<OrderTrackingRepository>(
    () => OrderTrackingRepositoryImpl(
      remote: ServiceLocator.instance(),
      zoneRepository: ServiceLocator.instance(),
    ),
  );

  /// DataSource
  ServiceLocator.instance.registerLazySingleton<OrderTrackingRemoteDataSource>(
    () =>
        OrderTrackingRemoteDataSourceImpl(consumer: ServiceLocator.instance()),
  );
}
