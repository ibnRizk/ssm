import '../../injection_container.dart';
import 'data/datasources/account_remote_data_source.dart';
import 'data/repos/account_repository_impl.dart';
import 'domain/repos/account_repository.dart';
import 'presentation/cubit/profile_cubit.dart';

/// Per-feature registration. See `home_injection.dart` for the convention.
///
/// [ProfileCubit] is screen-scoped — provided at the profile route in
/// `AppRoutes`.
Future<void> initAccountFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      accountRepository: ServiceLocator.instance(),
      loyaltyRepository: ServiceLocator.instance(),
    ),
  );

  /// Repository
  ServiceLocator.instance.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(remote: ServiceLocator.instance()),
  );

  /// DataSource
  ServiceLocator.instance.registerLazySingleton<AccountRemoteDataSource>(
    () => AccountRemoteDataSourceImpl(consumer: ServiceLocator.instance()),
  );
}
