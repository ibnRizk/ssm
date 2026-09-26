import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/modal_bottom_sheet_scaffold.dart';
import '../../domain/entities/delivery_zone.dart';

/// Every delivery zone, the current one checked. Pops the picked zone id.
class ZonePickerSheet extends StatelessWidget {
  final List<DeliveryZone> zones;
  final int? selectedZoneId;

  const ZonePickerSheet({
    super.key,
    required this.zones,
    required this.selectedZoneId,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return ModalBottomSheetScaffold(
      title: Strings.subscriptionsAreaSelectorTitle,
      child: ConstrainedBox(
        // Long zone lists scroll instead of pushing the sheet off-screen.
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.6,
        ),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.only(bottom: AppSpacing.md.h),
          itemCount: zones.length,
          separatorBuilder: (_, _) => SizedBox(height: 4.h),
          itemBuilder: (BuildContext context, int index) {
            final DeliveryZone zone = zones[index];
            final bool selected = zone.id == selectedZoneId;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.pop(context, zone.id),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md.w,
                  vertical: AppSpacing.sm.h,
                ),
                decoration: BoxDecoration(
                  color: selected ? c.primaryLight : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.md.r),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        zone.name,
                        style: AppTextStyles.titleSmall(
                          color: selected ? c.primary : c.textPrimary,
                        ),
                      ),
                    ),
                    if (selected)
                      Icon(Icons.check_circle, color: c.primary, size: 20.r),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
