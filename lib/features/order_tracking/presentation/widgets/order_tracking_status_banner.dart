import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// The dark navy "current status" hero card: status label, the active
/// step's own title blown up large in orange (so it can never drift out of
/// sync with the timeline below it), a short description, and the order
/// number.
class OrderTrackingStatusBanner extends StatelessWidget {
  final String currentStepTitle;
  final String orderNumber;

  const OrderTrackingStatusBanner({
    super.key,
    required this.currentStepTitle,
    required this.orderNumber,
  });

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
        children: <Widget>[
          Text(
            Strings.orderTrackingCurrentStatusLabel,
            style: AppTextStyles.caption(color: Colors.white),
          ),
          SizedBox(height: AppSpacing.xxs.h),
          Text(
            currentStepTitle,
            style: AppTextStyles.h1(color: c.secondary),
          ),
          SizedBox(height: AppSpacing.xs.h),
          Text(
            Strings.orderTrackingStatusDescription,
            style: AppTextStyles.caption(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            '${Strings.orderTrackingOrderNumberLabel} #$orderNumber',
            style: AppTextStyles.caption(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
