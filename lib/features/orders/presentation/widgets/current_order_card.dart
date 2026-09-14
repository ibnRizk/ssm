import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';

/// The dark navy "current order" card — status badge, item summary, and a
/// full-width white "track order" button. There's only ever one of these on
/// screen at a time, unlike [PastOrderCard], so its visual language (navy,
/// not white; inline white button, not a tinted one) is deliberately its
/// own widget rather than a variant flag on a shared card.
class CurrentOrderCard extends StatelessWidget {
  final String storeName;
  final String timeAndOrderId;
  final String statusLabel;
  final String itemsDescription;
  final int price;
  final IconData icon;
  final VoidCallback? onTrack;

  const CurrentOrderCard({
    super.key,
    required this.storeName,
    required this.timeAndOrderId,
    required this.statusLabel,
    required this.itemsDescription,
    required this.price,
    required this.icon,
    this.onTrack,
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: c.secondaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.md.r),
                ),
                child: Icon(icon, color: c.secondary, size: 20.r),
              ),
              SizedBox(width: AppSpacing.sm.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      storeName,
                      style: AppTextStyles.titleSmall(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      timeAndOrderId,
                      style: AppTextStyles.caption(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
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
                  color: c.secondary,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  statusLabel,
                  style: AppTextStyles.label(color: Colors.white),
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
                  style: AppTextStyles.caption(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: AppSpacing.sm.w),
              Text(
                '$price ر.س',
                style: AppTextStyles.titleSmall(color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md.h),
          AppButton(
            btnText: Strings.ordersTrackButton,
            onPressed: onTrack,
            color: c.surface,
            textColor: c.primary,
          ),
        ],
      ),
    );
  }
}
