import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/values/strings.dart';
import '../../core/widgets/coming_soon_screen.dart';
import '../../core/widgets/slider_photo.dart';
import '../../features/account/presentation/cubit/edit_profile_cubit.dart';
import '../../features/account/presentation/cubit/profile_cubit.dart';
import '../../features/account/presentation/screens/account_screen.dart';
import '../../features/account/presentation/screens/edit_profile_screen.dart';
import '../../features/addresses/presentation/cubit/add_address_cubit.dart';
import '../../features/addresses/presentation/cubit/addresses_cubit.dart';
import '../../features/addresses/presentation/screens/add_address_screen.dart';
import '../../features/addresses/presentation/screens/addresses_screen.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/catalog/domain/entities/store.dart';
import '../../features/checkout/presentation/cubit/checkout_cubit.dart';
import '../../features/checkout/presentation/screens/order_confirmation_screen.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/loyalty/presentation/cubit/loyalty_cubit.dart';
import '../../features/loyalty/presentation/screens/loyalty_screen.dart';
import '../../features/order_tracking/presentation/cubit/order_tracking_cubit.dart';
import '../../features/order_tracking/presentation/screens/order_tracking_screen.dart';
import '../../features/orders/presentation/cubit/orders_cubit.dart';
import '../../features/orders/presentation/cubit/reorder_cubit.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/parcels/presentation/cubit/parcels_cubit.dart';
import '../../features/parcels/presentation/screens/parcels_screen.dart';
import '../../features/pharmacy/presentation/cubit/pharmacy_order_cubit.dart';
import '../../features/pharmacy/presentation/screens/pharmacy_order_screen.dart';
import '../../features/restaurants/presentation/cubit/store_details_cubit.dart';
import '../../features/restaurants/presentation/cubit/stores_cubit.dart';
import '../../features/restaurants/presentation/screens/restaurant_details_screen.dart';
import '../../features/restaurants/presentation/screens/restaurants_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/subscriptions/presentation/cubit/subscriptions_cubit.dart';
import '../../features/subscriptions/presentation/screens/subscriptions_screen.dart';
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
  static const String storeDetails = '/store-details/:storeId';
  static String storeDetailsPath(int storeId) => '/store-details/$storeId';
  static const String cart = '/cart';
  static const String orderConfirmation = '/order-confirmation';
  static const String orderTracking = '/order-tracking/:orderId';
  static String orderTrackingPath(int orderId) => '/order-tracking/$orderId';
  static const String loyalty = '/loyalty';
  static const String restaurants = '/home/restaurants';
  static const String pharmacyOrder = '/home/pharmacy';
  static const String editProfile = '/edit-profile';
  static const String addresses = '/addresses';
  static const String addAddress = '/addresses/add';
  static const String helpSupport = '/help-support';

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
  static const String storeDetailsName = 'storeDetails';
  static const String cartName = 'cart';
  static const String orderConfirmationName = 'orderConfirmation';
  static const String orderTrackingName = 'orderTracking';
  static const String loyaltyName = 'loyalty';
  static const String restaurantsName = 'restaurants';
  static const String pharmacyOrderName = 'pharmacyOrder';
  static const String editProfileName = 'editProfile';
  static const String addressesName = 'addresses';
  static const String addAddressName = 'addAddress';
  static const String helpSupportName = 'helpSupport';

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
        builder: (_, __) => BlocProvider<AuthCubit>(
          create: (_) => ServiceLocator.instance<AuthCubit>(),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: register,
        name: registerName,
        builder: (_, __) => BlocProvider<AuthCubit>(
          create: (_) => ServiceLocator.instance<AuthCubit>(),
          child: const RegisterScreen(),
        ),
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
                builder: (_, __) => BlocProvider<HomeCubit>(
                  create: (_) => ServiceLocator.instance<HomeCubit>()..load(),
                  child: const HomeScreen(),
                ),
                routes: <RouteBase>[
                  // Relative to `home` — these stay inside its branch, so
                  // MainScaffold's bottom nav stays visible, unlike
                  // `storeDetails` below.
                  GoRoute(
                    path: 'restaurants',
                    name: restaurantsName,
                    builder: (_, __) => BlocProvider<StoresCubit>(
                      create: (_) =>
                          ServiceLocator.instance<StoresCubit>()..load(),
                      child: const RestaurantsScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'pharmacy',
                    name: pharmacyOrderName,
                    builder: (_, __) => BlocProvider<PharmacyOrderCubit>(
                      create: (_) =>
                          ServiceLocator.instance<PharmacyOrderCubit>()
                            ..loadOptions(),
                      child: const PharmacyOrderScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: orders,
                name: ordersName,
                builder: (_, __) => MultiBlocProvider(
                  providers: [
                    BlocProvider<OrdersCubit>(
                      create: (_) =>
                          ServiceLocator.instance<OrdersCubit>()..load(),
                    ),
                    BlocProvider<ReorderCubit>(
                      create: (_) => ServiceLocator.instance<ReorderCubit>(),
                    ),
                  ],
                  child: const OrdersScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: parcels,
                name: parcelsName,
                builder: (_, __) => BlocProvider<ParcelsCubit>(
                  create: (_) =>
                      ServiceLocator.instance<ParcelsCubit>()..fetchParcels(),
                  child: const ParcelsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: subscriptions,
                name: subscriptionsName,
                builder: (_, __) => BlocProvider<SubscriptionsCubit>(
                  create: (_) =>
                      ServiceLocator.instance<SubscriptionsCubit>()..load(),
                  child: const SubscriptionsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: profile,
                name: profileName,
                // ProfileCubit feeds the card and loyalty row; AuthCubit hosts
                // the logout action — see `AccountLogoutButton`.
                builder: (_, __) => MultiBlocProvider(
                  providers: [
                    BlocProvider<ProfileCubit>(
                      create: (_) =>
                          ServiceLocator.instance<ProfileCubit>()..load(),
                    ),
                    BlocProvider<AuthCubit>(
                      create: (_) => ServiceLocator.instance<AuthCubit>(),
                    ),
                  ],
                  child: const AccountScreen(),
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
              (state.extra as Map<String, dynamic>?) ?? <String, dynamic>{};
          return SliderPhotoScreen(
            imagesFiles: args['imagesFiles'],
            images: args['images'],
            path: args['path'],
            imageIndex: args['imageIndex'] ?? 0,
          );
        },
      ),

      // Outside the shell on purpose: an inner "detail" screen must never
      // show the bottom navigation bar, and only top-level routes (siblings
      // of the shell, not branches inside it) skip MainScaffold.
      GoRoute(
        path: storeDetails,
        name: storeDetailsName,
        builder: (_, GoRouterState state) {
          final int? storeId = int.tryParse(
            state.pathParameters['storeId'] ?? '',
          );
          if (storeId == null) {
            return Scaffold(
              body: Center(child: Text('No route found for ${state.uri}')),
            );
          }
          // The tapped list entry, so the header shows before the details
          // load; absent when the route is reached any other way.
          final Store? preview = state.extra is Store
              ? state.extra as Store
              : null;
          return MultiBlocProvider(
            providers: [
              BlocProvider<StoreDetailsCubit>(
                create: (_) => ServiceLocator.instance<StoreDetailsCubit>(
                  param1: storeId,
                  param2: preview,
                )..load(),
              ),
              BlocProvider<CartCubit>(
                create: (_) => ServiceLocator.instance<CartCubit>()..load(),
              ),
            ],
            child: const RestaurantDetailsScreen(),
          );
        },
      ),

      // Outside the shell for the same reason as `storeDetails` above: a
      // pushed inner screen, so no bottom navigation bar here even though
      // the design mock happened to include one.
      GoRoute(
        path: cart,
        name: cartName,
        builder: (_, GoRouterState state) =>
            _cartScope(state.extra, const CartScreen()),
      ),

      // Outside the shell for the same reason as `cart` above: a pushed
      // checkout screen, so no bottom navigation bar here even though the
      // design mock happened to include one (with a fake "confirm" tab).
      GoRoute(
        path: orderConfirmation,
        name: orderConfirmationName,
        builder: (_, GoRouterState state) => _cartScope(
          state.extra,
          BlocProvider<CheckoutCubit>(
            create: (_) =>
                ServiceLocator.instance<CheckoutCubit>()..loadAddresses(),
            child: const OrderConfirmationScreen(),
          ),
        ),
      ),

      // Outside the shell for the same reason as `orderConfirmation` above:
      // a pushed tracking screen, so no bottom navigation bar here even
      // though the design mock included one (with a fake "tracking" tab).
      GoRoute(
        path: orderTracking,
        name: orderTrackingName,
        builder: (_, GoRouterState state) {
          final int? orderId = int.tryParse(
            state.pathParameters['orderId'] ?? '',
          );
          if (orderId == null) {
            return Scaffold(
              body: Center(child: Text('No route found for ${state.uri}')),
            );
          }
          return BlocProvider<OrderTrackingCubit>(
            create: (_) =>
                ServiceLocator.instance<OrderTrackingCubit>(param1: orderId)
                  ..load(),
            child: const OrderTrackingScreen(),
          );
        },
      ),

      // Outside the shell for the same reason as `orderTracking` above: a
      // pushed inner screen, so no bottom navigation bar here.
      //
      // Linked from the Account tab's "نقاط الولاء" settings row via
      // `context.push(AppRoutes.loyalty)`.
      GoRoute(
        path: loyalty,
        name: loyaltyName,
        builder: (_, __) => BlocProvider<LoyaltyCubit>(
          create: (_) => ServiceLocator.instance<LoyaltyCubit>()..load(),
          child: const LoyaltyScreen(),
        ),
      ),

      // Pushed from the Account tab, outside the shell like `loyalty`.
      GoRoute(
        path: editProfile,
        name: editProfileName,
        builder: (_, GoRouterState state) {
          // The Account tab hands over its own ProfileCubit (see
          // `AccountProfileSection`) so a save updates the card behind this
          // screen. Reached any other way, it loads a fresh one.
          final ProfileCubit? profileCubit = state.extra as ProfileCubit?;
          return MultiBlocProvider(
            providers: [
              if (profileCubit != null)
                BlocProvider<ProfileCubit>.value(value: profileCubit)
              else
                BlocProvider<ProfileCubit>(
                  create: (_) =>
                      ServiceLocator.instance<ProfileCubit>()..load(),
                ),
              BlocProvider<EditProfileCubit>(
                create: (_) => ServiceLocator.instance<EditProfileCubit>(),
              ),
            ],
            child: const EditProfileScreen(),
          );
        },
      ),
      GoRoute(
        path: addresses,
        name: addressesName,
        builder: (_, __) => BlocProvider<AddressesCubit>(
          create: (_) => ServiceLocator.instance<AddressesCubit>()..load(),
          child: const AddressesScreen(),
        ),
        routes: <RouteBase>[
          // Pops `true` on save — see `AddressesScreen._openAddAddress`.
          GoRoute(
            path: 'add',
            name: addAddressName,
            builder: (_, __) => BlocProvider<AddAddressCubit>(
              create: (_) => ServiceLocator.instance<AddAddressCubit>(),
              child: const AddAddressScreen(),
            ),
          ),
        ],
      ),
      // Placeholder until its real screen exists.
      GoRoute(
        path: helpSupport,
        name: helpSupportName,
        builder: (_, __) => ComingSoonScreen(title: Strings.accountHelpTitle),
      ),
    ],
    errorBuilder: (_, GoRouterState state) =>
        Scaffold(body: Center(child: Text('No route found for ${state.uri}'))),
  );

  /// Cart and Checkout share the [CartCubit] the pushing screen hands over
  /// through `extra`, so they show — and change — the same cart. Reached
  /// any other way, they get (and close) a fresh one that loads the cart.
  static Widget _cartScope(Object? extra, Widget child) => extra is CartCubit
      ? BlocProvider<CartCubit>.value(value: extra, child: child)
      : BlocProvider<CartCubit>(
          create: (_) => ServiceLocator.instance<CartCubit>()..load(),
          child: child,
        );

  static String get currentRoute =>
      routesStack.isEmpty ? splash : routesStack.last;

  static void pushRouteToRoutesStack(String route) => routesStack.add(route);

  static void popRouteFromRoutesStack() {
    if (routesStack.isNotEmpty) routesStack.removeLast();
  }
}
