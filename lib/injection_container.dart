import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/locale/app_localizations.dart';
import 'config/themes/theme_cubit.dart';
import 'core/api/app_interceptors.dart';
import 'core/api/auth_event_bus.dart';
import 'core/api/dio_consumer.dart';
import 'core/services/local_storage/app_secure_storage.dart';
import 'core/services/local_storage/app_shared_preferences.dart';
import 'core/utils/values/app_colors.dart';
import 'features/home/home_injection.dart';
import 'features/language/language_injection.dart';

/// Composition root.
///
/// Order matters: core is registered first because feature registrations
/// resolve core services. Within a feature the convention is
/// cubit -> use case -> repository -> data source.
abstract class ServiceLocator {
  static final GetIt instance = GetIt.instance;

  static Future<void> init() async {
    // Lets AppColors / AppLocalizations be re-registered on theme and locale
    // changes instead of throwing.
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
    instance.registerLazySingleton<ThemeCubit>(() => ThemeCubit());

    // --- Features ---
    await initLanguageFeatureInjection();
    await initHomeFeatureInjection();
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

  /// Seeded at init with [AppColors.light], then refreshed from
  /// `MaterialApp.builder` on every theme change so the context-free [colors]
  /// getter tracks light/dark.
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

List<String> get routesStack =>
    ServiceLocator.instance<List<String>>(instanceName: 'routesStack');
