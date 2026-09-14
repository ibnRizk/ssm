import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

class SubscriptionArea {
  final String name;
  final int fee;

  const SubscriptionArea({required this.name, required this.fee});
}

/// Placeholder area/fee tiers, in reading order (right-to-left) — same
/// delivery zones referenced elsewhere (Cart, Order Confirmation, Pharmacy).
const List<SubscriptionArea> _placeholderAreas = <SubscriptionArea>[
  SubscriptionArea(name: 'تربة', fee: 10),
  SubscriptionArea(name: 'العلاوة', fee: 15),
  SubscriptionArea(name: 'الحايرة', fee: 20),
  SubscriptionArea(name: 'القويعية', fee: 22),
  SubscriptionArea(name: 'الحشرج', fee: 25),
];

/// The dark navy "choose your delivery area" card: a read-only dropdown
/// display, the pill row that actually drives the selection, and a fee note
/// for whichever area is picked. Which area is selected is pure UI state
/// that only affects this card's own fee note (unlike the package prices
/// below it, which the design keeps static), so it's `setState` scoped
/// entirely to this widget rather than lifted to the screen.
class SubscriptionsAreaCard extends StatefulWidget {
  const SubscriptionsAreaCard({super.key});

  @override
  State<SubscriptionsAreaCard> createState() => _SubscriptionsAreaCardState();
}

class _SubscriptionsAreaCardState extends State<SubscriptionsAreaCard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final SubscriptionArea selected = _placeholderAreas[_selectedIndex];
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: c.primary,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            Strings.subscriptionsAreaSelectorTitle,
            textAlign: TextAlign.right,
            style: AppTextStyles.caption(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Container(
            height: AppSizes.buttonHeight.h,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg.r),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    selected.name,
                    style: AppTextStyles.bodyLarge(color: c.textPrimary),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: c.textSecondary,
                  size: AppSizes.icon.r,
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                for (int i = 0; i < _placeholderAreas.length; i++) ...<Widget>[
                  if (i > 0) SizedBox(width: AppSpacing.xs.w),
                  _AreaPill(
                    label: _placeholderAreas[i].name,
                    selected: i == _selectedIndex,
                    onTap: () => setState(() => _selectedIndex = i),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            Strings.subscriptionsAreaFeeNote(selected.name, selected.fee),
            style: AppTextStyles.caption(color: c.secondary),
          ),
        ],
      ),
    );
  }
}

class _AreaPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AreaPill({
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
          horizontal: AppSpacing.sm.w,
          vertical: AppSpacing.xs.h,
        ),
        decoration: BoxDecoration(
          color: selected ? c.secondary : c.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption(
            color: selected ? Colors.white : c.secondary,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
