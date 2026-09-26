import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/env/app_env.dart';
import 'config/locale/app_localizations_setup.dart';
import 'config/locale/locale_cubit.dart';
import 'config/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'injection_container.dart';

/// Set this to your Figma frame size. Every `.w/.h/.sp/.r` is relative to it.
const Size kDesignSize = Size(390, 844);

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  StreamSubscription<void>? _unauthorizedSub;

  @override
  void initState() {
    super.initState();
    // Any 401/403 from any request lands here. Clear the session and bounce to
    // the app entry point — swap for your login route once auth exists.
    _unauthorizedSub = eventBus.unauthorizedStream.listen((
      _,
    ) async {
      await secureStorage.clearAll();
      AppRoutes.router.go(AppRoutes.login);
    });
  }

  @override
  void dispose() {
    _unauthorizedSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: kDesignSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<LocaleCubit>.value(
              value: localeCubit,
            ),
            BlocProvider<ThemeCubit>.value(
              value: themeCubit,
            ),
          ],
          child: BlocBuilder<LocaleCubit, Locale?>(
            builder: (BuildContext context, Locale? locale) {
              return BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (BuildContext context, ThemeMode themeMode) {
                  return MaterialApp.router(
                    // `'key'.tr` reads a global singleton, not `context` — plain
                    // const widgets deep in the tree won't re-run `build()` just
                    // because `locale` changed above them. Keying on the locale
                    // forces Flutter to remount the whole visual subtree so text
                    // actually refreshes; `AppRoutes.router` is a singleton, so
                    // navigation position survives the remount.
                    key: ValueKey<Locale?>(locale),
                    title: AppEnv.appName,
                    debugShowCheckedModeBanner: false,
                    theme: appTheme,
                    darkTheme: appThemeDark,
                    themeMode: themeMode,
                    // Null until the user explicitly picks a language in the
                    // Account tab — `localeResolutionCallback` below then keeps
                    // following the device locale, same as before that choice.
                    locale: locale,
                    supportedLocales: AppLocalizationsSetup
                        .supportedLocales,
                    localizationsDelegates:
                        AppLocalizationsSetup
                            .localizationsDelegates,
                    localeResolutionCallback:
                        AppLocalizationsSetup
                            .localeResolutionCallback,
                    routerConfig: AppRoutes.router,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
