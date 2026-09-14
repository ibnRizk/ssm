import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// The single "cash on delivery" payment method. No picker — there's only
/// one option right now, so this is a static display card, not a chooser.
class OrderConfirmationPaymentCard extends StatelessWidget {
  const OrderConfirmationPaymentCard({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      width: double.infinity,
      decoration: AppDecorations.card(),
      padding: EdgeInsets.all(AppSpacing.md.r),
      child: Row(
        children: <Widget>[
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: c.successLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.payments_outlined, color: c.success, size: 20.r),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  Strings.orderConfirmationPaymentTitle,
                  style: AppTextStyles.titleSmall(color: c.textPrimary),
                ),
                SizedBox(height: 2.h),
                Text(
                  Strings.orderConfirmationPaymentDescription,
                  style: AppTextStyles.caption(color: c.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
