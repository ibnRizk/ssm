import '../../injection_container.dart';
import 'presentation/cubit/store_cart_cubit.dart';

/// Per-feature registration. See `home_injection.dart` for the convention
/// this mirrors: cubits are `registerFactory` (fresh instance per screen).
///
/// [StoreCartCubit] is screen-scoped, so unlike an app-wide cubit it isn't
/// exposed as a `List<BlocProvider>` here — it's provided directly at the
/// route in `AppRoutes` instead.
Future<void> initRestaurantsFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance.registerFactory<StoreCartCubit>(
    () => StoreCartCubit(),
  );
}
