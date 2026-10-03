import '../../injection_container.dart';
import 'data/datasources/account_remote_data_source.dart';
import 'data/repos/account_repository_impl.dart';
import 'domain/repos/account_repository.dart';
import 'presentation/cubit/delete_account_cubit.dart';
import 'presentation/cubit/edit_profile_cubit.dart';
import 'presentation/cubit/profile_cubit.dart';

/// Per-feature registration. See `home_injection.dart` for the convention.
///
/// [ProfileCubit] is screen-scoped — provided at the profile route in
/// `AppRoutes`, and handed to Edit Profile through `extra`.
Future<void> initAccountFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      accountRepository: ServiceLocator.instance(),
      loyaltyRepository: ServiceLocator.instance(),
    ),
  );
  ServiceLocator.instance.registerFactory<EditProfileCubit>(
    () => EditProfileCubit(repository: ServiceLocator.instance()),
  );
  ServiceLocator.instance.registerFactory<DeleteAccountCubit>(
    () => DeleteAccountCubit(
      accountRepository: ServiceLocator.instance(),
      authRepository: ServiceLocator.instance(),
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
