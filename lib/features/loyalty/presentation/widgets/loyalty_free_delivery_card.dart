import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// Free-delivery balance: how many are ready to use, or — when none are —
/// how they're earned.
class LoyaltyFreeDeliveryCard extends StatelessWidget {
  final int availableFreeDeliveries;
  final int eligibleOrdersRequired;

  const LoyaltyFreeDeliveryCard({
    super.key,
    required this.availableFreeDeliveries,
    required this.eligibleOrdersRequired,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final bool hasAvailable = availableFreeDeliveries > 0;
    return Container(
      width: double.infinity,
      decoration: AppDecorations.card(c),
      padding: EdgeInsets.all(AppSpacing.md.r),
      child: Row(
        children: <Widget>[
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: hasAvailable ? c.successLight : c.secondaryLight,
              borderRadius: BorderRadius.circular(AppRadius.md.r),
            ),
            child: Icon(
              Icons.eco,
              color: hasAvailable ? c.success : c.secondary,
              size: 20.r,
            ),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  Strings.loyaltyFreeDeliveryTitle,
                  style: AppTextStyles.titleSmall(color: c.textPrimary),
                ),
                SizedBox(height: 2.h),
                Text(
                  hasAvailable
                      ? Strings.loyaltyFreeDeliveriesAvailable(
                          availableFreeDeliveries,
                        )
                      : Strings.loyaltyFreeDeliverySubtitle(
                          eligibleOrdersRequired,
                        ),
                  style: AppTextStyles.caption(
                    color: hasAvailable ? c.success : c.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (hasAvailable)
            Text(
              '$availableFreeDeliveries',
              style: AppTextStyles.h2(color: c.success),
            ),
        ],
      ),
    );
  }
}
