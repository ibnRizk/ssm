import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

class _HomeCategory {
  final String label;
  final IconData icon;

  /// Pharmacy gets the distinct light-green / "+" treatment in the design.
  final bool featured;

  const _HomeCategory({
    required this.label,
    required this.icon,
    this.featured = false,
  });
}

/// Placeholder categories, in reading order (right-to-left, as an Arabic
/// speaker reads them) — swap for real data from the catalog feature once it
/// exists. [Row] lays children start-to-end (right-to-left under the app's
/// RTL layout), so listing them in reading order reproduces the design's
/// exact grid position without hardcoding a physical side anywhere.
const List<_HomeCategory> _placeholderCategories = <_HomeCategory>[
  _HomeCategory(label: 'مطاعم', icon: Icons.restaurant_outlined),
  _HomeCategory(label: 'كافيهات', icon: Icons.coffee_outlined),
  _HomeCategory(label: 'سوبرماركت', icon: Icons.shopping_cart_outlined),
  _HomeCategory(label: 'معسلات', icon: Icons.smoking_rooms_outlined),
  _HomeCategory(label: 'صيدليات', icon: Icons.add, featured: true),
];

class HomeCategoriesSection extends StatelessWidget {
  const HomeCategoriesSection({super.key});

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
            // TODO: navigate to the full categories list once it exists.
            GestureDetector(
              onTap: () {},
              child: Text(
                Strings.homeViewAll,
                style: AppTextStyles.titleSmall(color: c.secondary),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md.h),
        _CategoryRow(items: _placeholderCategories.sublist(0, 3)),
        SizedBox(height: AppSpacing.sm.h),
        // Only 2 categories on this row — the design leaves the third slot
        // (the row's *first*, i.e. rightmost, reading-order position) empty.
        _CategoryRow(
          items: _placeholderCategories.sublist(3, 5),
          leadingGap: true,
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final List<_HomeCategory> items;
  final bool leadingGap;

  const _CategoryRow({required this.items, this.leadingGap = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        if (leadingGap) ...<Widget>[
          const Expanded(child: SizedBox()),
          SizedBox(width: AppSpacing.sm.w),
        ],
        for (int i = 0; i < items.length; i++) ...<Widget>[
          if (i > 0) SizedBox(width: AppSpacing.sm.w),
          Expanded(child: _CategoryCard(category: items[i])),
        ],
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _HomeCategory category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final bool featured = category.featured;
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
      decoration: featured
          ? BoxDecoration(
              color: c.successLight,
              borderRadius: BorderRadius.circular(AppRadius.lg.r),
            )
          : AppDecorations.card(),
      child: Column(
        children: <Widget>[
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: featured ? c.success : c.primaryLight,
            ),
            child: Icon(
              category.icon,
              color: featured ? Colors.white : c.primary,
              size: 20.r,
            ),
          ),
          SizedBox(height: AppSpacing.xs.h),
          Text(
            category.label,
            style: AppTextStyles.caption(color: c.textPrimary),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
