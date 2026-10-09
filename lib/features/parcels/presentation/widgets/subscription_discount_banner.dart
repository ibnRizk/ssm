import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// Green confirmation above the payment summary: a parcel plan was applied
/// to this quote, and how many deliveries are left on it.
class SubscriptionDiscountBanner extends StatelessWidget {
  /// Null when the server didn't say — the banner then omits the count.
  final int? remainingDeliveries;

  const SubscriptionDiscountBanner({super.key, this.remainingDeliveries});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final int? remaining = remainingDeliveries;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md.w,
        vertical: AppSpacing.sm.h,
      ),
      decoration: BoxDecoration(
        color: c.successLight,
        borderRadius: BorderRadius.circular(AppRadius.md.r),
        border: Border.all(color: c.success),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.check_circle, color: c.success, size: 22.r),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Text(
              remaining == null
                  ? Strings.sendParcelDiscountAppliedNoCount
                  : Strings.sendParcelDiscountApplied(remaining),
              style: AppTextStyles.titleSmall(color: c.success),
            ),
          ),
        ],
      ),
    );
  }
}
