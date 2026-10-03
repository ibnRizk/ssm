import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/locale/app_localizations.dart';
import 'config/locale/locale_cubit.dart';
import 'core/api/app_interceptors.dart';
import 'core/app_config/app_config_remote_data_source.dart';
import 'core/app_config/app_config_repository.dart';
import 'core/app_config/app_config_repository_impl.dart';
import 'core/app_config/app_version.dart';
import 'core/app_config/installed_app.dart';
import 'core/api/auth_event_bus.dart';
import 'core/api/dio_consumer.dart';
import 'core/location/device_location_data_source.dart';
import 'core/location/location_repository.dart';
import 'core/location/location_repository_impl.dart';
import 'core/services/local_storage/app_secure_storage.dart';
import 'core/services/local_storage/app_shared_preferences.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/theme_cubit.dart';
import 'core/zone/zone_remote_data_source.dart';
import 'core/zone/zone_repository.dart';
import 'core/zone/zone_repository_impl.dart';
import 'features/account/account_injection.dart';
import 'features/addresses/addresses_injection.dart';
import 'features/auth/auth_injection.dart';
import 'features/cart/cart_injection.dart';
import 'features/catalog/catalog_injection.dart';
import 'features/checkout/checkout_injection.dart';
import 'features/home/home_injection.dart';
import 'features/order_tracking/order_tracking_injection.dart';
import 'features/orders/orders_injection.dart';
import 'features/parcels/parcels_injection.dart';
import 'features/pharmacy/pharmacy_injection.dart';
import 'features/loyalty/loyalty_injection.dart';
import 'features/restaurants/restaurants_injection.dart';
import 'features/splash/splash_injection.dart';
import 'features/subscriptions/subscriptions_injection.dart';

/// Composition root.
///
/// Order matters: core is registered first because feature registrations
/// resolve core services. Within a feature the convention is
/// cubit -> use case -> repository -> data source.
abstract class ServiceLocator {
  static final GetIt instance = GetIt.instance;

  static Future<void> init() async {
    // Lets AppLocalizations be re-registered on locale changes instead of
    // throwing.
    instance.allowReassignment = true;

    // --- Core ---
    await _injectSharedPreferences();
    _injectSecureStorage();
    _injectEventBus();
    _injectAppInterceptors();
    _injectLogInterceptor();
    _injectDioConsumer();
    _injectLocation();
    _injectZone();
    await _injectAppConfig();
    injectAppColors(AppColors.light);
    injectRoutesStackSingleton(<String>[]);
    _injectLocaleCubit();
    _injectThemeCubit();

    // --- Features ---
    await initSplashFeatureInjection();
    await initAuthFeatureInjection();
    await initAccountFeatureInjection();
    await initAddressesFeatureInjection();
    await initLoyaltyFeatureInjection();
    await initCatalogFeatureInjection();
    await initCartFeatureInjection();
    await initCheckoutFeatureInjection();
    await initOrderTrackingFeatureInjection();
    await initOrdersFeatureInjection();
    await initHomeFeatureInjection();
    await initParcelsFeatureInjection();
    await initPharmacyFeatureInjection();
    await initRestaurantsFeatureInjection();
    await initSubscriptionsFeatureInjection();
    // Register new features here.
  }

  static Future<void> _injectSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    instance.registerLazySingleton<AppSharedPreferences>(
      () => AppSharedPreferencesImpl(instance: prefs),
    );
  }

  static void _injectSecureStorage() {
    const AndroidOptions androidOptions = AndroidOptions(
      encryptedSharedPreferences: true,
    );
    const FlutterSecureStorage storage = FlutterSecureStorage(
      aOptions: androidOptions,
    );
    instance.registerLazySingleton<AppSecureStorage>(
      () => AppSecureStorageImpl(instance: storage),
    );
  }

  static void _injectLocaleCubit() =>
      instance.registerLazySingleton<LocaleCubit>(
        () => LocaleCubit(sharedPreferences: instance()),
      );

  static void _injectThemeCubit() => instance.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(sharedPreferences: instance()),
  );

  static void _injectDioConsumer() => instance
      .registerLazySingleton<DioConsumer>(() => DioConsumerImpl(client: Dio()));

  /// Device GPS — shared by Add Address and the parcels drop-off.
  static void _injectLocation() {
    instance.registerLazySingleton<DeviceLocationDataSource>(
      () => DeviceLocationDataSourceImpl(),
    );
    instance.registerLazySingleton<LocationRepository>(
      () => LocationRepositoryImpl(device: instance()),
    );
  }

  /// The delivery zone behind the `zoneId` header — shared by every
  /// shopping feature (catalog now; cart and orders next).
  static void _injectZone() {
    instance.registerLazySingleton<ZoneRemoteDataSource>(
      () => ZoneRemoteDataSourceImpl(consumer: instance()),
    );
    instance.registerLazySingleton<ZoneRepository>(
      () => ZoneRepositoryImpl(
        remote: instance(),
        location: instance(),
        preferences: instance(),
      ),
    );
  }

  /// `GET /config/customer` and the build it's checked against — the splash
  /// gate today; support and legal screens read the same config.
  static Future<void> _injectAppConfig() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    instance.registerSingleton<InstalledApp>(
      InstalledApp(
        version: AppVersion.tryParse(info.version),
        platform: Platform.isAndroid
            ? AppPlatform.android
            : Platform.isIOS
            ? AppPlatform.ios
            : AppPlatform.other,
      ),
    );
    instance.registerLazySingleton<AppConfigRemoteDataSource>(
      () => AppConfigRemoteDataSourceImpl(consumer: instance()),
    );
    instance.registerLazySingleton<AppConfigRepository>(
      () => AppConfigRepositoryImpl(remote: instance()),
    );
  }

  static void _injectEventBus() =>
      instance.registerLazySingleton<AuthEventBus>(() => AuthEventBus.instance);

  static void _injectAppInterceptors() =>
      instance.registerLazySingleton<AppInterceptors>(() => AppInterceptors());

  static void _injectLogInterceptor() =>
      instance.registerLazySingleton<LogInterceptor>(
        () => LogInterceptor(
          request: true,
          requestBody: true,
          requestHeader: true,
          responseBody: true,
          responseHeader: false,
          error: true,
        ),
      );

  /// Backs the context-free [colors] getter. The app is light-only, so this
  /// is registered once at init and never changes.
  static void injectAppColors(AppColors appColors) =>
      instance.registerSingleton<AppColors>(appColors);

  /// Called from `AppLocalizationsDelegate.load` so the `'key'.tr` extension
  /// works without a BuildContext.
  static void injectAppLocalizations(AppLocalizations appLocalizations) =>
      instance.registerSingleton<AppLocalizations>(appLocalizations);

  static void injectRoutesStackSingleton(List<String> routes) =>
      instance.registerLazySingleton<List<String>>(
        () => routes,
        instanceName: 'routesStack',
      );
}

// --- Global accessors ---------------------------------------------------

AppSharedPreferences get sharedPreferences =>
    ServiceLocator.instance<AppSharedPreferences>();

AppSecureStorage get secureStorage =>
    ServiceLocator.instance<AppSecureStorage>();

DioConsumer get dioConsumer => ServiceLocator.instance<DioConsumer>();

AuthEventBus get eventBus => ServiceLocator.instance<AuthEventBus>();

AppInterceptors get appInterceptors =>
    ServiceLocator.instance<AppInterceptors>();

LogInterceptor get logInterceptor => ServiceLocator.instance<LogInterceptor>();

AppColors get colors => ServiceLocator.instance<AppColors>();

AppLocalizations get appLocalizations =>
    ServiceLocator.instance<AppLocalizations>();

LocaleCubit get localeCubit => ServiceLocator.instance<LocaleCubit>();

ThemeCubit get themeCubit => ServiceLocator.instance<ThemeCubit>();

List<String> get routesStack =>
    ServiceLocator.instance<List<String>>(instanceName: 'routesStack');
