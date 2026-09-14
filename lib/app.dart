import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/env/app_env.dart';
import 'config/locale/app_localizations_setup.dart';
import 'config/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
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
    _unauthorizedSub = eventBus.unauthorizedStream.listen((_) async {
      await secureStorage.clearAll();
      AppRoutes.router.go(AppRoutes.splash);
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
        return MaterialApp.router(
          title: AppEnv.appName,
          debugShowCheckedModeBanner: false,
          // Light only — the SSM design has no dark variant.
          theme: appTheme,
          themeMode: ThemeMode.light,
          supportedLocales: AppLocalizationsSetup.supportedLocales,
          localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
          localeResolutionCallback:
              AppLocalizationsSetup.localeResolutionCallback,
          routerConfig: AppRoutes.router,
        );
      },
    );
  }
}
