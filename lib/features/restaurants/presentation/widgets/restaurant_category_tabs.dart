import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// Which category tab is highlighted is pure UI state — no business logic —
/// so it's `setState`, scoped to just this row, same treatment as
/// [RestaurantFilterChips].
///
/// TODO: filter the products list by category once the catalog has more
/// than one section's worth of mock data.
class RestaurantCategoryTabs extends StatefulWidget {
  const RestaurantCategoryTabs({super.key});

  @override
  State<RestaurantCategoryTabs> createState() =>
      _RestaurantCategoryTabsState();
}

class _RestaurantCategoryTabsState extends State<RestaurantCategoryTabs> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final List<String> labels = <String>[
      Strings.storeDetailsTabMostOrdered,
      Strings.storeDetailsTabMeals,
      Strings.storeDetailsTabAddons,
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (int i = 0; i < labels.length; i++)
            Padding(
              padding: EdgeInsetsDirectional.only(start: i > 0 ? AppSpacing.lg.w : 0),
              child: _CategoryTab(
                label: labels[i],
                selected: i == _selectedIndex,
                onTap: () => setState(() => _selectedIndex = i),
                color: c,
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final AppColors color;

  const _CategoryTab({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: selected
                ? AppTextStyles.titleSmall(color: color.textPrimary)
                : AppTextStyles.body(color: color.textSecondary),
          ),
          SizedBox(height: AppSpacing.xs.h),
          Container(
            height: 2.h,
            width: 28.w,
            color: selected ? color.secondary : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
