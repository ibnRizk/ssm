import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/delivery_zone.dart';
import 'zone_picker_sheet.dart';

/// The dark navy "choose your delivery area" card: a dropdown that opens
/// the full zone list, and a row of pills below it for quick switching.
/// Both report the pick through [onSelected]; the selection itself lives in
/// the cubit, since it drives the plans below.
class SubscriptionsAreaCard extends StatelessWidget {
  final List<DeliveryZone> zones;
  final int? selectedZoneId;
  final ValueChanged<int> onSelected;

  const SubscriptionsAreaCard({
    super.key,
    required this.zones,
    required this.selectedZoneId,
    required this.onSelected,
  });

  Future<void> _openPicker(BuildContext context) async {
    final int? picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) =>
          ZonePickerSheet(zones: zones, selectedZoneId: selectedZoneId),
    );
    if (picked != null) onSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    DeliveryZone? selected;
    for (final DeliveryZone zone in zones) {
      if (zone.id == selectedZoneId) selected = zone;
    }

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
            style: AppTextStyles.caption(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          GestureDetector(
            onTap: zones.isEmpty ? null : () => _openPicker(context),
            child: Container(
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
                      selected?.name ?? Strings.subscriptionsNoZones,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyLarge(
                        color: selected == null ? c.textHint : c.textPrimary,
                      ),
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
          ),
          if (zones.length > 1) ...<Widget>[
            SizedBox(height: AppSpacing.sm.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  for (int i = 0; i < zones.length; i++) ...<Widget>[
                    if (i > 0) SizedBox(width: AppSpacing.xs.w),
                    _AreaPill(
                      label: zones[i].name,
                      selected: zones[i].id == selectedZoneId,
                      onTap: () => onSelected(zones[i].id),
                    ),
                  ],
                ],
              ),
            ),
          ],
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
