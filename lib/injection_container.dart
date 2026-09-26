import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/locale/app_localizations.dart';
import 'config/locale/locale_cubit.dart';
import 'core/api/app_interceptors.dart';
import 'core/api/auth_event_bus.dart';
import 'core/api/dio_consumer.dart';
import 'core/services/local_storage/app_secure_storage.dart';
import 'core/services/local_storage/app_shared_preferences.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/auth_injection.dart';
import 'features/home/home_injection.dart';
import 'features/restaurants/restaurants_injection.dart';

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
    injectAppColors(AppColors.light);
    injectRoutesStackSingleton(<String>[]);
    _injectLocaleCubit();
    _injectThemeCubit();

    // --- Features ---
    await initAuthFeatureInjection();
    await initHomeFeatureInjection();
    await initRestaurantsFeatureInjection();
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

  static void _injectLocaleCubit() => instance.registerLazySingleton<LocaleCubit>(
    () => LocaleCubit(sharedPreferences: instance()),
  );

  static void _injectThemeCubit() => instance.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(sharedPreferences: instance()),
  );

  static void _injectDioConsumer() => instance
      .registerLazySingleton<DioConsumer>(() => DioConsumerImpl(client: Dio()));

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
