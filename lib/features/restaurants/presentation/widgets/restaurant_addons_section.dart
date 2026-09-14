import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../cubit/store_cart_cubit.dart';
import '../cubit/store_cart_state.dart';

class RestaurantAddon {
  final String id;
  final String label;
  final int extraPrice;

  const RestaurantAddon({
    required this.id,
    required this.label,
    required this.extraPrice,
  });
}

/// The dark navy "choose add-ons" box — a checkbox per [addons] entry,
/// toggled through [StoreCartCubit].
class RestaurantAddonsSection extends StatelessWidget {
  final List<RestaurantAddon> addons;

  const RestaurantAddonsSection({super.key, required this.addons});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: c.primary,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            Strings.storeDetailsAddonsTitle,
            style: AppTextStyles.titleSmall(color: Colors.white),
          ),
          SizedBox(height: AppSpacing.sm.h),
          BlocBuilder<StoreCartCubit, StoreCartState>(
            builder: (BuildContext context, StoreCartState state) {
              return Wrap(
                spacing: AppSpacing.lg.w,
                runSpacing: AppSpacing.sm.h,
                children: <Widget>[
                  for (final RestaurantAddon addon in addons)
                    _AddonTile(
                      addon: addon,
                      selected: state.isAddonSelected(addon.id),
                      onTap: () =>
                          context.read<StoreCartCubit>().toggleAddon(
                            addon.id,
                          ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AddonTile extends StatelessWidget {
  final RestaurantAddon addon;
  final bool selected;
  final VoidCallback onTap;

  const _AddonTile({
    required this.addon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 18.r,
            height: 18.r,
            decoration: BoxDecoration(
              color: selected ? context.colors.secondary : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.sm.r / 2),
              border: Border.all(
                color: selected
                    ? context.colors.secondary
                    : Colors.white.withValues(alpha: 0.6),
              ),
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
          SizedBox(width: AppSpacing.xs.w),
          Text(
            '${addon.label} +${addon.extraPrice}',
            style: AppTextStyles.caption(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
