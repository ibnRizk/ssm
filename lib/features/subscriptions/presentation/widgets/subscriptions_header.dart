import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// Title/subtitle on the start side — same start-first shape as
/// [HomeHeader]. Subscriptions is a bottom-nav tab root (see
/// [ParcelsHeader]), so — unlike a pushed screen — it must not show a back
/// button.
class SubscriptionsHeader extends StatelessWidget {
  const SubscriptionsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Column(
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
    );
  }
}
