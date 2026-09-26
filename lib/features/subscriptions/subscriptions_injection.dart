import '../../injection_container.dart';
import 'data/datasources/subscriptions_remote_data_source.dart';
import 'data/repos/subscriptions_repository_impl.dart';
import 'domain/repos/subscriptions_repository.dart';
import 'presentation/cubit/subscriptions_cubit.dart';

/// Per-feature registration. See `home_injection.dart` for the convention.
///
/// [SubscriptionsCubit] is screen-scoped — provided at the subscriptions
/// route in `AppRoutes`.
Future<void> initSubscriptionsFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance.registerFactory<SubscriptionsCubit>(
    () => SubscriptionsCubit(repository: ServiceLocator.instance()),
  );

  /// Repository
  ServiceLocator.instance.registerLazySingleton<SubscriptionsRepository>(
    () => SubscriptionsRepositoryImpl(remote: ServiceLocator.instance()),
  );

  /// DataSource
  ServiceLocator.instance.registerLazySingleton<SubscriptionsRemoteDataSource>(
    () =>
        SubscriptionsRemoteDataSourceImpl(consumer: ServiceLocator.instance()),
  );
}
