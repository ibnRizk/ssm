import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// Title/subtitle on the start side, a circular action button on the end
/// side — same start-first/end-last shape as [HomeHeader], just with a
/// chevron instead of an avatar. Subscriptions is a tab root (see
/// [ParcelsHeader]), so the chevron is decorative, not a real back button.
class SubscriptionsHeader extends StatelessWidget {
  const SubscriptionsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                Strings.subscriptionsTitle,
                style: AppTextStyles.h1(color: c.textPrimary),
              ),
              SizedBox(height: AppSpacing.xxs.h),
              Text(
                Strings.subscriptionsSubtitle,
                style: AppTextStyles.caption(color: c.textSecondary),
              ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.sm.w),
        Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: c.border),
          ),
          child: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward
                : Icons.arrow_back,
            size: 18.r,
            color: c.textPrimary,
          ),
        ),
      ],
    );
  }
}
