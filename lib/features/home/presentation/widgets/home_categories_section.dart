import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../catalog/domain/entities/catalog_category.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

/// The zone's categories plus the pharmacy request, in a 3-column grid.
/// Pharmacy isn't a catalog category — it's its own request flow — so it
/// keeps the design's distinct light-green "+" card at the end.
class HomeCategoriesSection extends StatelessWidget {
  const HomeCategoriesSection({super.key});

  /// Two rows of three, the last slot being pharmacy.
  static const int _maxCategories = 5;
  static const int _columns = 3;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                Strings.homeCategoriesTitle,
                style: AppTextStyles.h2(color: c.textPrimary),
              ),
            ),
            GestureDetector(
              onTap: () => context.push(AppRoutes.restaurants),
              child: Text(
                Strings.homeViewAll,
                style: AppTextStyles.titleSmall(color: c.secondary),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md.h),
        BlocSelector<HomeCubit, HomeState, List<CatalogCategory>>(
          selector: (HomeState state) => state is HomeLoaded
              ? state.categories
              : const <CatalogCategory>[],
          builder: (BuildContext context, List<CatalogCategory> categories) {
            final List<Widget> cards = <Widget>[
              for (final CatalogCategory category in categories.take(
                _maxCategories,
              ))
                _CategoryCard(
                  label: category.name,
                  imageUrl: category.imageUrl,
                  // No category filter for stores exists in the API yet,
                  // so every category opens the zone's store list.
                  onTap: () => context.push(AppRoutes.restaurants),
                ),
              _CategoryCard(
                label: Strings.homePharmacyCategory,
                featured: true,
                onTap: () => context.push(AppRoutes.pharmacyOrder),
              ),
            ];
            // `Wrap` with an explicit item width, so a short last row is
            // centered as a group instead of stretched or pushed to a side
            // (which looks unbalanced under RTL).
            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double gap = AppSpacing.sm.w;
                final double itemWidth =
                    (constraints.maxWidth - gap * (_columns - 1)) / _columns;
                return Wrap(
                  alignment: WrapAlignment.center,
                  spacing: gap,
                  runSpacing: AppSpacing.sm.h,
                  children: <Widget>[
                    for (final Widget card in cards)
                      SizedBox(width: itemWidth, child: card),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String label;
  final String? imageUrl;

  /// Pharmacy gets the distinct light-green / "+" treatment in the design.
  final bool featured;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.label,
    required this.onTap,
    this.imageUrl,
    this.featured = false,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
        decoration: featured
            ? BoxDecoration(
                color: c.successLight,
                borderRadius: BorderRadius.circular(AppRadius.lg.r),
              )
            : AppDecorations.card(c),
        child: Column(
          children: <Widget>[
            AppNetworkImage(
              url: imageUrl,
              width: 40.r,
              height: 40.r,
              borderRadius: BorderRadius.circular(20.r),
              fallback: ColoredBox(
                color: featured ? c.success : c.primaryLight,
                child: Icon(
                  featured ? Icons.add : Icons.category_outlined,
                  color: featured ? Colors.white : c.primary,
                  size: 20.r,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xs.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxs.w),
              child: Text(
                label,
                style: AppTextStyles.caption(color: c.textPrimary),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
