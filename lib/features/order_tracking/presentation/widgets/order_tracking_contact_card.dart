import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// Who's handling the order (the store, or the courier once one is on it)
/// and, when there's a number to dial, a one-tap call button.
class OrderTrackingContactCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final VoidCallback? onCall;

  const OrderTrackingContactCard({
    super.key,
    required this.name,
    required this.subtitle,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      width: double.infinity,
      decoration: AppDecorations.card(c),
      padding: EdgeInsets.all(AppSpacing.md.r),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: AppTextStyles.titleSmall(color: c.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: AppTextStyles.caption(color: c.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onCall != null) ...<Widget>[
            SizedBox(width: AppSpacing.sm.w),
            GestureDetector(
              onTap: onCall,
              child: Text(
                Strings.orderTrackingCallButton,
                style: AppTextStyles.titleSmall(color: c.secondary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
