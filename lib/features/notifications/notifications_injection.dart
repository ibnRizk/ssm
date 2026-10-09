import '../../injection_container.dart';
import 'data/datasources/notifications_remote_data_source.dart';
import 'data/repos/notifications_repository_impl.dart';
import 'domain/repos/notifications_repository.dart';
import 'presentation/cubit/notification_hub_cubit.dart';
import 'presentation/cubit/notifications_cubit.dart';

/// Per-feature registration. See `home_injection.dart` for the convention.
///
/// [NotificationHubCubit] is provided at the bottom-nav shell route (it
/// lives exactly as long as the signed-in session); [NotificationsCubit] at
/// the inbox route. Push and realtime come from core.
Future<void> initNotificationsFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance.registerFactory<NotificationHubCubit>(
    () => NotificationHubCubit(
      push: ServiceLocator.instance(),
      realtime: ServiceLocator.instance(),
      notifications: ServiceLocator.instance(),
    ),
  );
  ServiceLocator.instance.registerFactory<NotificationsCubit>(
    () => NotificationsCubit(
      repository: ServiceLocator.instance(),
      realtime: ServiceLocator.instance(),
    ),
  );

  /// Repository — a singleton: its read-state stream is shared by the
  /// inbox and the hub.
  ServiceLocator.instance.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(remote: ServiceLocator.instance()),
  );

  /// DataSource
  ServiceLocator.instance.registerLazySingleton<NotificationsRemoteDataSource>(
    () =>
        NotificationsRemoteDataSourceImpl(consumer: ServiceLocator.instance()),
  );
}
