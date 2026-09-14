import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../cubit/store_cart_cubit.dart';
import '../widgets/restaurant_addons_section.dart';
import '../widgets/restaurant_cart_bar.dart';
import '../widgets/restaurant_category_tabs.dart';
import '../widgets/restaurant_details_header.dart';
import '../widgets/restaurant_info_card.dart';
import '../widgets/restaurant_product_card.dart';

class _ProductListItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final IconData icon;
  final Color Function(AppColors) iconBackground;
  final Color Function(AppColors) iconColor;

  const _ProductListItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
  });
}

/// Placeholder menu — swap for real data from the store's catalog once that
/// data layer exists.
const List<_ProductListItem> _placeholderProducts = <_ProductListItem>[
  _ProductListItem(
    id: 'ssm-burger-meal',
    name: 'وجبة برجر SSM',
    description: 'برجر لحم، بطاطس، ومشروب غازي',
    price: 28,
    icon: Icons.lunch_dining,
    iconBackground: _peach,
    iconColor: _peachIcon,
  ),
  _ProductListItem(
    id: 'grilled-chicken-meal',
    name: 'وجبة دجاج مشوي',
    description: 'نصف دجاجة، أرز، صوص وثومية',
    price: 32,
    icon: Icons.kebab_dining,
    iconBackground: _blue,
    iconColor: _blueIcon,
  ),
];

const List<RestaurantAddon> _placeholderAddons = <RestaurantAddon>[
  RestaurantAddon(id: 'cheese', label: 'جبنة', extraPrice: 3),
  RestaurantAddon(id: 'sauce', label: 'صوص', extraPrice: 2),
  RestaurantAddon(id: 'fries', label: 'بطاطس', extraPrice: 4),
];

Color _peach(AppColors c) => c.secondaryLight;
Color _peachIcon(AppColors c) => c.secondary;
Color _blue(AppColors c) => c.info.withValues(alpha: 0.12);
Color _blueIcon(AppColors c) => c.info;

const double _rating = 4.8;
const String _etaLabel = '25–35 دقيقة';
const String _deliveryFeeLabel = 'توصيل 7 ر.س';

/// Full store-details screen — unlike the tab bodies (Home, Parcels,
/// Restaurants list), this owns its own [Scaffold]: it's pushed as a
/// top-level route outside [MainScaffold]'s shell, so the bottom navigation
/// bar never shows here (see the "no bottom nav on inner screens" rule).
///
/// [StoreCartCubit] is provided by the route in `AppRoutes`, not by this
/// widget — it's screen-scoped but this screen's own subtree (header, info
/// card) doesn't need it, only the product/add-on/cart-bar children do.
class RestaurantDetailsScreen extends StatelessWidget {
  final String storeName;
  final String storeSubtitle;

  static const double _cardOverlap = 56;

  /// Used both as this widget's own defaults and by `AppRoutes` when the
  /// pushing screen doesn't pass a real store's name/subtitle.
  static const String defaultStoreName = 'مطاعم مذاق';
  static const String defaultStoreSubtitle = 'برجر • مشويات • وجبات سريعة';

  const RestaurantDetailsScreen({
    super.key,
    this.storeName = defaultStoreName,
    this.storeSubtitle = defaultStoreSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                RestaurantDetailsHeader(
                  storeName: storeName,
                  storeSubtitle: storeSubtitle,
                  onBack: () => context.pop(),
                ),
                Positioned(
                  left: AppSpacing.screen.w,
                  right: AppSpacing.screen.w,
                  bottom: -_cardOverlap.h,
                  child: RestaurantInfoCard(
                    storeName: storeName,
                    rating: _rating,
                    etaLabel: _etaLabel,
                    deliveryFeeLabel: _deliveryFeeLabel,
                  ),
                ),
              ],
            ),
            SizedBox(height: _cardOverlap.h + AppSpacing.lg.h),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screen.w,
                  0,
                  AppSpacing.screen.w,
                  AppSpacing.xxl.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const RestaurantCategoryTabs(),
                    SizedBox(height: AppSpacing.sm.h),
                    Divider(color: c.border, height: 1),
                    SizedBox(height: AppSpacing.md.h),
                    Text(
                      Strings.storeDetailsSectionTitle,
                      style: AppTextStyles.h2(color: c.textPrimary),
                    ),
                    SizedBox(height: AppSpacing.md.h),
                    for (int i = 0; i < _placeholderProducts.length; i++) ...<Widget>[
                      if (i > 0) SizedBox(height: AppSpacing.md.h),
                      RestaurantProductCard(
                        id: _placeholderProducts[i].id,
                        name: _placeholderProducts[i].name,
                        description: _placeholderProducts[i].description,
                        price: _placeholderProducts[i].price,
                        icon: _placeholderProducts[i].icon,
                        iconBackground: _placeholderProducts[i].iconBackground(
                          c,
                        ),
                        iconColor: _placeholderProducts[i].iconColor(c),
                        storeName: storeName,
                      ),
                    ],
                    SizedBox(height: AppSpacing.lg.h),
                    const RestaurantAddonsSection(addons: _placeholderAddons),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: RestaurantCartBar(
        // Hand the *same* cubit instance to the Cart route via `extra` — a
        // fresh `BlocProvider(create: ...)` there would resolve a brand-new
        // instance from get_it's factory and the cart would appear empty.
        onViewCart: () => context.push(
          AppRoutes.cart,
          extra: context.read<StoreCartCubit>(),
        ),
      ),
    );
  }
}
