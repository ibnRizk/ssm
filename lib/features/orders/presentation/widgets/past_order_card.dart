import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// A finished-order card: white background, a status badge (green once
/// delivered), and a soft tinted-orange "reorder" button — the opposite
/// palette from [CurrentOrderCard] by design (white, not navy; tinted
/// button, not solid).
class PastOrderCard extends StatelessWidget {
  final String storeName;
  final String dateAndOrderId;
  final String itemsDescription;
  final String priceLabel;
  final String statusLabel;
  final Color statusBackground;
  final Color statusColor;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;

  /// Shows a spinner in place of the button's label.
  final bool reordering;

  /// Null disables the button.
  final VoidCallback? onReorder;

  const PastOrderCard({
    super.key,
    required this.storeName,
    required this.dateAndOrderId,
    required this.itemsDescription,
    required this.priceLabel,
    required this.statusLabel,
    required this.statusBackground,
    required this.statusColor,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    this.reordering = false,
    this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: AppDecorations.card(c),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(AppRadius.md.r),
                ),
                child: Icon(icon, color: iconColor, size: 20.r),
              ),
              SizedBox(width: AppSpacing.sm.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      storeName,
                      style: AppTextStyles.titleSmall(color: c.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      dateAndOrderId,
                      style: AppTextStyles.caption(color: c.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.xs.w),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  statusLabel,
                  style: AppTextStyles.label(color: statusColor),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md.h),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  itemsDescription,
                  style: AppTextStyles.caption(color: c.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: AppSpacing.sm.w),
              Text(
                priceLabel,
                style: AppTextStyles.titleSmall(color: c.textPrimary),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md.h),
          GestureDetector(
            onTap: reordering ? null : onReorder,
            child: Container(
              width: double.infinity,
              height: AppSizes.buttonHeight.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.secondaryLight,
                borderRadius: BorderRadius.circular(AppRadius.lg.r),
              ),
              child: reordering
                  ? SizedBox.square(
                      dimension: 20.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: c.secondary,
                      ),
                    )
                  : Text(
                      Strings.ordersReorderButton,
                      style: AppTextStyles.button(color: c.secondary),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
