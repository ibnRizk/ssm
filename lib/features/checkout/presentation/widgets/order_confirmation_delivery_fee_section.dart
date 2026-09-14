import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

class DeliveryArea {
  final String name;
  final int fee;

  const DeliveryArea({required this.name, required this.fee});
}

/// The dark navy "current area fee" card plus the scrollable row of area
/// options below it. Stateless on purpose: which area is selected is owned
/// by [OrderConfirmationScreen] (the nearest ancestor that also needs the
/// fee, for the order total) rather than buried in this widget where a
/// sibling section couldn't reach it.
class OrderConfirmationDeliveryFeeSection extends StatelessWidget {
  final List<DeliveryArea> areas;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const OrderConfirmationDeliveryFeeSection({
    super.key,
    required this.areas,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final DeliveryArea selected = areas[selectedIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.md.r),
          decoration: BoxDecoration(
            color: c.primary,
            borderRadius: BorderRadius.circular(AppRadius.lg.r),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'منطقة ${selected.name}',
                      style: AppTextStyles.titleSmall(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      Strings.orderConfirmationAreaCardSubtitle,
                      style: AppTextStyles.caption(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.sm.w),
              Text(
                '${selected.fee} ر.س',
                style: AppTextStyles.h2(color: c.secondary),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.sm.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              for (int i = 0; i < areas.length; i++) ...<Widget>[
                if (i > 0) SizedBox(width: AppSpacing.sm.w),
                _AreaChip(
                  area: areas[i],
                  selected: i == selectedIndex,
                  onTap: () => onSelected(i),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AreaChip extends StatelessWidget {
  final DeliveryArea area;
  final bool selected;
  final VoidCallback onTap;

  const _AreaChip({
    required this.area,
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
          horizontal: AppSpacing.sm.w,
          vertical: AppSpacing.xs.h,
        ),
        decoration: BoxDecoration(
          color: selected ? c.secondaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          '${area.name} ${area.fee}',
          style: AppTextStyles.caption(
            color: selected ? c.secondary : c.textSecondary,
          ).copyWith(fontWeight: selected ? FontWeight.w700 : null),
        ),
      ),
    );
  }
}
