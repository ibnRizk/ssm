import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/values/strings.dart';
import '../../core/widgets/slider_photo.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/parcels/presentation/screens/parcels_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../injection_container.dart';
import 'main_scaffold.dart';
import 'navigator_observer.dart';

abstract class AppRoutes {
  // --- Paths (for context.go / context.push) ---
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String orders = '/orders';
  static const String parcels = '/parcels';
  static const String subscriptions = '/subscriptions';
  static const String profile = '/profile';
  static const String photoViewer = '/photo-viewer';

  // --- Names (for context.goNamed / context.pushNamed) ---
  static const String splashName = 'splash';
  static const String loginName = 'login';
  static const String registerName = 'register';
  static const String homeName = 'home';
  static const String ordersName = 'orders';
  static const String parcelsName = 'parcels';
  static const String subscriptionsName = 'subscriptions';
  static const String profileName = 'profile';
  static const String photoViewerName = 'photoViewer';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    observers: <NavigatorObserver>[AppNavigatorObserver()],
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      GoRoute(
        path: splash,
        name: splashName,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: login,
        name: loginName,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        name: registerName,
        builder: (_, __) => const RegisterScreen(),
      ),

      // Bottom-nav shell — each branch below keeps its own navigation stack
      // (see MainScaffold). Push further screens *inside* a tab (e.g. order
      // details) as children of that branch's GoRoute; routes outside the
      // shell — auth, full-screen flows — belong at the top level, like
      // `photoViewer` below.
      StatefulShellRoute.indexedStack(
        builder: (_, __, StatefulNavigationShell shell) =>
            MainScaffold(navigationShell: shell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: home,
                name: homeName,
                builder: (_, __) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: orders,
                name: ordersName,
                builder: (_, __) => ShellTabPlaceholder(
                  label: Strings.navOrders,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: parcels,
                name: parcelsName,
                builder: (_, __) => const ParcelsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: subscriptions,
                name: subscriptionsName,
                builder: (_, __) => ShellTabPlaceholder(
                  label: Strings.navSubscriptions,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: profile,
                name: profileName,
                builder: (_, __) => ShellTabPlaceholder(
                  label: Strings.navProfile,
                ),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: photoViewer,
        name: photoViewerName,
        builder: (_, GoRouterState state) {
          final Map<String, dynamic> args =
              (state.extra as Map<String, dynamic>?) ??
              <String, dynamic>{};
          return SliderPhotoScreen(
            imagesFiles: args['imagesFiles'],
            images: args['images'],
            path: args['path'],
            imageIndex: args['imageIndex'] ?? 0,
          );
        },
      ),
    ],
    errorBuilder: (_, GoRouterState state) => Scaffold(
      body: Center(
        child: Text('No route found for ${state.uri}'),
      ),
    ),
  );

  static String get currentRoute =>
      routesStack.isEmpty ? splash : routesStack.last;

  static void pushRouteToRoutesStack(String route) =>
      routesStack.add(route);

  static void popRouteFromRoutesStack() {
    if (routesStack.isNotEmpty) routesStack.removeLast();
  }
}
