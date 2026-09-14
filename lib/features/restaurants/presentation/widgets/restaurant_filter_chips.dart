import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// The sort/filter pill row. Which chip is active is pure UI state — no
/// business logic — so it's `setState`, scoped to just this row rather than
/// the whole screen.
///
/// TODO: thread the selected sort back to a real restaurants query once that
/// data layer exists.
class RestaurantFilterChips extends StatefulWidget {
  const RestaurantFilterChips({super.key});

  @override
  State<RestaurantFilterChips> createState() => _RestaurantFilterChipsState();
}

class _RestaurantFilterChipsState extends State<RestaurantFilterChips> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> labels = <String>[
      Strings.restaurantsFilterNearest,
      Strings.restaurantsFilterTopRated,
      Strings.restaurantsFilterFastest,
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (int i = 0; i < labels.length; i++) ...<Widget>[
            if (i > 0) SizedBox(width: AppSpacing.sm.w),
            _FilterChip(
              label: labels[i],
              selected: i == _selectedIndex,
              onTap: () => setState(() => _selectedIndex = i),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md.w,
          vertical: AppSpacing.xs.h,
        ),
        decoration: BoxDecoration(
          color: selected ? c.primary : c.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: selected ? null : Border.all(color: c.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.titleSmall(
            color: selected ? Colors.white : c.textSecondary,
          ),
        ),
      ),
    );
  }
}
