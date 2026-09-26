import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// A parcel still being processed — not at the warehouse yet, so there's
/// nothing to track or act on.
class PendingShipmentCard extends StatelessWidget {
  final String reference;
  final VoidCallback? onTap;

  const PendingShipmentCard({super.key, required this.reference, this.onTap});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg.r),
      child: Container(
        decoration: AppDecorations.card(c),
        padding: EdgeInsets.all(AppSpacing.md.r),
        child: Row(
          children: <Widget>[
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: c.secondaryLight,
                borderRadius: BorderRadius.circular(AppRadius.md.r),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                color: c.secondary,
                size: 20.r,
              ),
            ),
            SizedBox(width: AppSpacing.sm.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Strings.parcelsPendingTitle,
                    style: AppTextStyles.titleSmall(color: c.textPrimary),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${Strings.parcelsShipmentReference(reference)} · '
                    '${Strings.parcelsPendingSubtitle}',
                    style: AppTextStyles.caption(color: c.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left
                  : Icons.chevron_right,
              color: c.textHint,
            ),
          ],
        ),
      ),
    );
  }
}
