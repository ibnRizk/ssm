import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/env/app_env.dart';
import 'config/locale/app_localizations_setup.dart';
import 'config/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/language/language_injection.dart';
import 'features/language/presentation/cubit/locale_cubit/locale_cubit.dart';
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
    return MultiBlocProvider(
      providers: <BlocProvider<StateStreamableSource<Object?>>>[
        ...languageBlocs,
      ],
      child: ScreenUtilInit(
        designSize: kDesignSize,
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, __) {
          return BlocBuilder<LocaleCubit, LocaleState>(
            buildWhen: (LocaleState p, LocaleState c) =>
                p.locale.languageCode != c.locale.languageCode,
            builder: (_, LocaleState localeState) {
              return MaterialApp.router(
                title: AppEnv.appName,
                debugShowCheckedModeBanner: false,
                // Light only — the SSM design has no dark variant.
                theme: appTheme,
                themeMode: ThemeMode.light,
                locale: localeState.locale,
                supportedLocales: AppLocalizationsSetup.supportedLocales,
                localizationsDelegates:
                    AppLocalizationsSetup.localizationsDelegates,
                localeResolutionCallback:
                    AppLocalizationsSetup.localeResolutionCallback,
                routerConfig: AppRoutes.router,
              );
            },
          );
        },
      ),
    );
  }
}
