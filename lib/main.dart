import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'config/env/app_env.dart';
import 'core/services/bloc_observer/bloc_observer.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Environment first — DioConsumer reads AppEnv.baseUrl in its constructor.
  await AppEnv.load();

  // 2. Dependency injection.
  await ServiceLocator.init();

  // 3. System chrome.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light, // iOS
      statusBarIconBrightness: Brightness.dark, // Android
    ),
  );
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 4. Bloc logging.
  Bloc.observer = AppBlocObserver();

  runApp(const App());
}
