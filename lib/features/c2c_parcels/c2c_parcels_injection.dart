import '../../injection_container.dart';
import 'data/datasources/c2c_parcels_remote_data_source.dart';
import 'data/datasources/c2c_photo_picker_data_source.dart';
import 'data/repos/c2c_parcels_repository_impl.dart';
import 'domain/entities/c2c_parcel.dart';
import 'domain/repos/c2c_parcels_repository.dart';
import 'presentation/cubit/c2c_parcel_tracking_cubit.dart';
import 'presentation/cubit/c2c_parcels_list_cubit.dart';
import 'presentation/cubit/create_parcel_cubit.dart';
import 'presentation/cubit/send_parcel_cubit.dart';

/// Per-feature registration. See `home_injection.dart` for the convention.
///
/// Every cubit is screen-scoped — provided at its route in `AppRoutes`.
/// The device location and the realtime feed come from core.
Future<void> initC2cParcelsFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance.registerFactory<SendParcelCubit>(
    () => SendParcelCubit(
      repository: ServiceLocator.instance(),
      locationRepository: ServiceLocator.instance(),
    ),
  );
  ServiceLocator.instance
      .registerFactoryParam<CreateParcelCubit, CreateParcelArgs, void>(
        (CreateParcelArgs args, _) => CreateParcelCubit(
          repository: ServiceLocator.instance(),
          request: args.request,
          quote: args.quote,
        ),
      );
  ServiceLocator.instance
      .registerFactoryParam<C2cParcelsListCubit, C2cParcelBox, void>(
        (C2cParcelBox box, _) => C2cParcelsListCubit(
          box: box,
          repository: ServiceLocator.instance(),
        ),
      );
  ServiceLocator.instance
      .registerFactoryParam<C2cParcelTrackingCubit, int, void>(
        (int parcelId, _) => C2cParcelTrackingCubit(
          parcelId: parcelId,
          repository: ServiceLocator.instance(),
          realtime: ServiceLocator.instance(),
        ),
      );

  /// Repository
  ServiceLocator.instance.registerLazySingleton<C2cParcelsRepository>(
    () => C2cParcelsRepositoryImpl(
      remote: ServiceLocator.instance(),
      photoPicker: ServiceLocator.instance(),
    ),
  );

  /// DataSource
  ServiceLocator.instance.registerLazySingleton<C2cParcelsRemoteDataSource>(
    () => C2cParcelsRemoteDataSourceImpl(consumer: ServiceLocator.instance()),
  );
  ServiceLocator.instance.registerLazySingleton<C2cPhotoPickerDataSource>(
    C2cPhotoPickerDataSourceImpl.new,
  );
}
