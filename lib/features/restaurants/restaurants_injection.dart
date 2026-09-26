import '../../injection_container.dart';
import '../catalog/domain/entities/store.dart';
import 'presentation/cubit/store_details_cubit.dart';
import 'presentation/cubit/stores_cubit.dart';

/// Per-feature registration. See `home_injection.dart` for the convention
/// this mirrors: cubits are `registerFactory` (fresh instance per screen).
///
/// These cubits are screen-scoped, so unlike an app-wide cubit they aren't
/// exposed as a `List<BlocProvider>` here — they're provided directly at
/// the routes in `AppRoutes` instead. The catalog feature registers the
/// repository they browse; the cart feature, the cart they fill.
Future<void> initRestaurantsFeatureInjection() async {
  /// Cubits
  /// Param: the category to list, or null for every store of the zone.
  ServiceLocator.instance.registerFactoryParam<StoresCubit, int?, void>(
    (int? categoryId, _) => StoresCubit(
      repository: ServiceLocator.instance(),
      categoryId: categoryId,
    ),
  );

  /// Params: the store id, and the list entry that was tapped (if any).
  ServiceLocator.instance.registerFactoryParam<StoreDetailsCubit, int, Store?>(
    (int storeId, Store? preview) => StoreDetailsCubit(
      repository: ServiceLocator.instance(),
      storeId: storeId,
      preview: preview,
    ),
  );
}
