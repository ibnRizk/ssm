import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'config/env/app_env.dart';
import 'core/push/push_background_handler.dart';
import 'core/push/push_repository.dart';
import 'core/services/bloc_observer/bloc_observer.dart';
import 'core/utils/log_utils.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Environment first — DioConsumer reads AppEnv.baseUrl in its constructor.
  await AppEnv.load();

  // 2. Firebase, before anything touches FCM. Fails soft: until
  // `google-services.json` / `GoogleService-Info.plist` are added this
  // throws, and the app runs without push (see `PushUnavailableFailure`).
  await _initFirebase();

  // 3. Dependency injection.
  await ServiceLocator.init();

  // 4. Push banners and tap routing. A no-op without Firebase.
  await ServiceLocator.instance<PushRepository>().initialize();

  // 5. System chrome.
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

  // 6. Bloc logging.
  Bloc.observer = AppBlocObserver();

  runApp(const App());
}

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp();
    // Registered before `runApp` so a push arriving while killed is drawn.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (error) {
    Log.w('Firebase unavailable, running without push: $error');
  }
}
