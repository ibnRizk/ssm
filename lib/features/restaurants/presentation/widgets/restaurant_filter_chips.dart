import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../catalog/domain/entities/store_sort.dart';
import '../cubit/stores_cubit.dart';
import '../cubit/stores_state.dart';

/// The sort pill row of the zone-wide stores list. The active chip is the
/// [StoresCubit]'s sort; tapping it again restores the default order. A
/// search can't be sorted, so the row hides while one is shown.
class RestaurantFilterChips extends StatelessWidget {
  const RestaurantFilterChips({super.key});

  static const List<StoreSort> _sorts = StoreSort.values;

  static String _label(StoreSort sort) => switch (sort) {
    StoreSort.nearest => Strings.restaurantsFilterNearest,
    StoreSort.topRated => Strings.restaurantsFilterTopRated,
    StoreSort.fastest => Strings.restaurantsFilterFastest,
  };

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      StoresCubit,
      StoresState,
      ({bool searching, StoreSort? sort})
    >(
      selector: (StoresState state) =>
          (searching: state.query.isNotEmpty, sort: state.sort),
      builder: (BuildContext context, ({bool searching, StoreSort? sort}) s) {
        if (s.searching) return const SizedBox.shrink();
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              for (int i = 0; i < _sorts.length; i++) ...<Widget>[
                if (i > 0) SizedBox(width: AppSpacing.sm.w),
                _FilterChip(
                  label: _label(_sorts[i]),
                  selected: _sorts[i] == s.sort,
                  onTap: () => context.read<StoresCubit>().sortBy(
                    _sorts[i] == s.sort ? null : _sorts[i],
                  ),
                ),
              ],
            ],
          ),
        );
      },
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
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
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
      ),
    );
  }
}
