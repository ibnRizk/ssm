import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/restaurant_filter_chips.dart';
import '../widgets/restaurants_header.dart';

class _RestaurantListItem {
  final String name;
  final List<String> categories;
  final String etaLabel;
  final String deliveryFeeLabel;
  final double rating;
  final IconData icon;
  final Color Function(AppColors) iconBackground;
  final Color Function(AppColors) iconColor;
  // A closure, not a resolved String: `_placeholderRestaurants` is a
  // top-level `final` built once, so a raw `Strings.*` value captured here
  // would freeze at the first-ever locale and go stale on a language switch.
  final String Function()? badgeLabel;

  const _RestaurantListItem({
    required this.name,
    required this.categories,
    required this.etaLabel,
    required this.deliveryFeeLabel,
    required this.rating,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    this.badgeLabel,
  });
}

/// Placeholder store list — swap for real data from the restaurants feature's
/// data layer once it exists.
final List<_RestaurantListItem> _placeholderRestaurants = <_RestaurantListItem>[
  _RestaurantListItem(
    name: 'مطاعم مذاق',
    categories: const <String>['برجر', 'مشويات'],
    etaLabel: '25–35 دقيقة',
    deliveryFeeLabel: 'رسوم التوصيل 7 ر.س',
    rating: 4.8,
    icon: Icons.lunch_dining,
    iconBackground: (AppColors c) => c.secondaryLight,
    iconColor: (AppColors c) => c.secondary,
  ),
  _RestaurantListItem(
    name: 'مشويات السرايا',
    categories: const <String>['مشويات', 'أطباق عربية'],
    etaLabel: '30–40 دقيقة',
    deliveryFeeLabel: 'توصيل مجاني',
    rating: 4.7,
    icon: Icons.kebab_dining,
    iconBackground: (AppColors c) => c.info.withValues(alpha: 0.12),
    iconColor: (AppColors c) => c.info,
    badgeLabel: () => Strings.restaurantsBadgeTodayOffer,
  ),
  _RestaurantListItem(
    name: 'برجر هاوس',
    categories: const <String>['برجر', 'بيتزا', 'وجبات'],
    etaLabel: '20–30 دقيقة',
    deliveryFeeLabel: 'رسوم التوصيل 5 ر.س',
    rating: 4.6,
    icon: Icons.local_pizza,
    iconBackground: (AppColors c) => c.errorLight,
    iconColor: (AppColors c) => c.error,
  ),
];

/// Restaurants list tab body. The bottom navigation bar and its Scaffold live
/// in [MainScaffold] — this widget is only the scrollable content for that
/// tab.
class RestaurantsScreen extends StatelessWidget {
  const RestaurantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screen.w,
          AppSpacing.lg.h,
          AppSpacing.screen.w,
          AppSpacing.xxl.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RestaurantsHeader(onBack: () => context.pop()),
            SizedBox(height: AppSpacing.lg.h),
            const RestaurantFilterChips(),
            SizedBox(height: AppSpacing.xl.h),
            Text(
              Strings.restaurantsSectionTitle,
              style: AppTextStyles.body(color: c.textSecondary),
            ),
            SizedBox(height: AppSpacing.md.h),
            for (int i = 0; i < _placeholderRestaurants.length; i++) ...<Widget>[
              if (i > 0) SizedBox(height: AppSpacing.lg.h),
              RestaurantCard(
                name: _placeholderRestaurants[i].name,
                categories: _placeholderRestaurants[i].categories,
                etaLabel: _placeholderRestaurants[i].etaLabel,
                deliveryFeeLabel: _placeholderRestaurants[i].deliveryFeeLabel,
                rating: _placeholderRestaurants[i].rating,
                icon: _placeholderRestaurants[i].icon,
                iconBackground: _placeholderRestaurants[i].iconBackground(c),
                iconColor: _placeholderRestaurants[i].iconColor(c),
                badgeLabel: _placeholderRestaurants[i].badgeLabel?.call(),
                onTap: () => context.push(
                  AppRoutes.storeDetails,
                  extra: <String, String>{
                    'storeName': _placeholderRestaurants[i].name,
                    'storeSubtitle': _placeholderRestaurants[i].categories
                        .join(' • '),
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
