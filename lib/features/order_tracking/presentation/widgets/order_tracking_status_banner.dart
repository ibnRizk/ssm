import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// The dark navy "current status" hero card: status label, the headline
/// blown up large in orange, a short description, the order number, and
/// — when the last refresh failed — a note that the status may be behind.
/// [waiting] adds a running progress bar while the order waits on something
/// that happens without the customer (finding a courier).
class OrderTrackingStatusBanner extends StatelessWidget {
  final String headline;
  final String description;
  final int orderId;
  final bool stale;
  final bool waiting;

  const OrderTrackingStatusBanner({
    super.key,
    required this.headline,
    required this.description,
    required this.orderId,
    this.stale = false,
    this.waiting = false,
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
          Text(headline, style: AppTextStyles.h1(color: c.secondary)),
          if (waiting) ...<Widget>[
            SizedBox(height: AppSpacing.xs.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg.r),
              child: LinearProgressIndicator(
                minHeight: 3,
                color: c.secondary,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ],
          SizedBox(height: AppSpacing.xs.h),
          Text(
            description,
            style: AppTextStyles.caption(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            '${Strings.orderTrackingOrderNumberLabel} #$orderId',
            style: AppTextStyles.caption(color: Colors.white),
          ),
          if (stale) ...<Widget>[
            SizedBox(height: AppSpacing.xs.h),
            Text(
              Strings.orderTrackingStale,
              style: AppTextStyles.caption(color: c.secondary),
            ),
          ],
        ],
      ),
    );
  }
}
