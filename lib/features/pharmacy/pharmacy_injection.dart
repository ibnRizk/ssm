import '../../injection_container.dart';
import 'data/datasources/pharmacy_remote_data_source.dart';
import 'data/datasources/prescription_picker_data_source.dart';
import 'data/repos/pharmacy_repository_impl.dart';
import 'domain/repos/pharmacy_repository.dart';
import 'presentation/cubit/pharmacy_order_cubit.dart';

/// Per-feature registration. See `home_injection.dart` for the convention.
///
/// [PharmacyOrderCubit] is screen-scoped — provided at the pharmacy route
/// in `AppRoutes`. It also browses the catalog (for pharmacies) and the
/// customer's addresses, registered by those features.
Future<void> initPharmacyFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance.registerFactory<PharmacyOrderCubit>(
    () => PharmacyOrderCubit(
      pharmacyRepository: ServiceLocator.instance(),
      catalogRepository: ServiceLocator.instance(),
      addressRepository: ServiceLocator.instance(),
    ),
  );

  /// Repository
  ServiceLocator.instance.registerLazySingleton<PharmacyRepository>(
    () => PharmacyRepositoryImpl(
      remote: ServiceLocator.instance(),
      picker: ServiceLocator.instance(),
    ),
  );

  /// DataSources
  ServiceLocator.instance.registerLazySingleton<PharmacyRemoteDataSource>(
    () => PharmacyRemoteDataSourceImpl(consumer: ServiceLocator.instance()),
  );
  ServiceLocator.instance.registerLazySingleton<PrescriptionPickerDataSource>(
    () => PrescriptionPickerDataSourceImpl(),
  );
}
