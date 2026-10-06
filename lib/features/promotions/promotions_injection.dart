import '../../injection_container.dart';
import 'data/datasources/promotions_remote_data_source.dart';
import 'data/repos/promotions_repository_impl.dart';
import 'domain/repos/promotions_repository.dart';
import 'presentation/cubit/promotions_cubit.dart';

/// Per-feature registration. See `home_injection.dart` for the convention.
///
/// [PromotionsCubit] is screen-scoped — provided at the home route next to
/// `HomeCubit`.
Future<void> initPromotionsFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance.registerFactory<PromotionsCubit>(
    () => PromotionsCubit(
      promotionsRepository: ServiceLocator.instance(),
      zoneRepository: ServiceLocator.instance(),
    ),
  );

  /// Repository
  ServiceLocator.instance.registerLazySingleton<PromotionsRepository>(
    () => PromotionsRepositoryImpl(
      remote: ServiceLocator.instance(),
      zoneRepository: ServiceLocator.instance(),
    ),
  );

  /// DataSource
  ServiceLocator.instance.registerLazySingleton<PromotionsRemoteDataSource>(
    () => PromotionsRemoteDataSourceImpl(consumer: ServiceLocator.instance()),
  );
}
