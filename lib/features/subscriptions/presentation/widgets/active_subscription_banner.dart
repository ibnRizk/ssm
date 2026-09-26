import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/active_subscription.dart';

/// Small green strip at the top of the tab: the active plan and how many
/// deliveries are left on it.
class ActiveSubscriptionBanner extends StatelessWidget {
  final ActiveSubscription subscription;

  const ActiveSubscriptionBanner({super.key, required this.subscription});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final DateTime? expiresAt = subscription.expiresAt;
    final String details = <String>[
      Strings.subscriptionsActiveRemaining(
        subscription.deliveriesRemaining,
        subscription.deliveriesTotal,
      ),
      if (expiresAt != null)
        Strings.subscriptionsActiveExpires(
          DateFormat.yMMMd(
            Localizations.localeOf(context).languageCode,
          ).format(expiresAt.toLocal()),
        ),
    ].join(' · ');

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md.w,
        vertical: AppSpacing.sm.h,
      ),
      decoration: BoxDecoration(
        color: c.successLight,
        borderRadius: BorderRadius.circular(AppRadius.md.r),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.verified_outlined, color: c.success, size: 22.r),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  subscription.planName == null
                      ? Strings.subscriptionsActiveTitle
                      : '${Strings.subscriptionsActiveTitle} · '
                            '${subscription.planName}',
                  style: AppTextStyles.titleSmall(color: c.success),
                ),
                SizedBox(height: 2.h),
                Text(
                  details,
                  style: AppTextStyles.caption(color: c.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
