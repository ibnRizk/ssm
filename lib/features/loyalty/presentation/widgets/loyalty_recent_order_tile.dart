import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// One "+1 completed order" tile in the recent-orders row. Wrap in
/// `Expanded` at the call site so three of them share the row evenly.
class LoyaltyRecentOrderTile extends StatelessWidget {
  const LoyaltyRecentOrderTile({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      width: double.infinity,
      decoration: AppDecorations.card(c),
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
      child: Column(
        children: <Widget>[
          Text('+1', style: AppTextStyles.title(color: c.textPrimary)),
          SizedBox(height: AppSpacing.xxs.h),
          Text(
            Strings.loyaltyCompletedOrderLabel,
            style: AppTextStyles.caption(color: c.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
