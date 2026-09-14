import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// The dark-navy delivery-fee summary above the submit button.
///
/// [label] and [feeLabel] are placeholder values — swap for the resolved
/// zone and a real quoted fee once the pricing feature exists (same pattern
/// as [HomeOffersSection]'s placeholder zone/price line).
class PharmacyDeliveryFeeCard extends StatelessWidget {
  final String label;
  final String feeLabel;

  const PharmacyDeliveryFeeCard({
    super.key,
    required this.label,
    required this.feeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md.w,
        vertical: AppSpacing.sm.h,
      ),
      decoration: BoxDecoration(
        color: c.primary,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body(color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Text(
            feeLabel,
            style: AppTextStyles.h2(color: c.secondary),
          ),
        ],
      ),
    );
  }
}
