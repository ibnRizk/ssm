import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// The delivery-address card: pin badge, two lines of text, and an action
/// link ("Change", or "Add address" when there's none yet).
class OrderConfirmationAddressCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String actionLabel;
  final VoidCallback? onAction;

  const OrderConfirmationAddressCard({
    super.key,
    required this.title,
    required this.actionLabel,
    this.subtitle,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final String? subtitle = this.subtitle;
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
              color: c.secondaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.location_on, color: c.secondary, size: 20.r),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: AppTextStyles.titleSmall(color: c.textPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...<Widget>[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption(color: c.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: AppSpacing.xs.w),
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel,
              style: AppTextStyles.titleSmall(color: c.secondary),
            ),
          ),
        ],
      ),
    );
  }
}
