import '../../injection_container.dart';
import 'data/datasources/orders_remote_data_source.dart';
import 'data/repos/orders_repository_impl.dart';
import 'domain/repos/orders_repository.dart';
import 'presentation/cubit/orders_cubit.dart';
import 'presentation/cubit/reorder_cubit.dart';

/// Per-feature registration. See `home_injection.dart` for the convention.
///
/// [ReorderCubit] also needs the cart feature's `CartRepository`.
Future<void> initOrdersFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance.registerFactory<OrdersCubit>(
    () => OrdersCubit(
      repository: ServiceLocator.instance(),
      realtime: ServiceLocator.instance(),
    ),
  );
  ServiceLocator.instance.registerFactory<ReorderCubit>(
    () => ReorderCubit(
      ordersRepository: ServiceLocator.instance(),
      cartRepository: ServiceLocator.instance(),
    ),
  );

  /// Repository
  ServiceLocator.instance.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(
      remote: ServiceLocator.instance(),
      zoneRepository: ServiceLocator.instance(),
    ),
  );

  /// DataSource
  ServiceLocator.instance.registerLazySingleton<OrdersRemoteDataSource>(
    () => OrdersRemoteDataSourceImpl(consumer: ServiceLocator.instance()),
  );
}
