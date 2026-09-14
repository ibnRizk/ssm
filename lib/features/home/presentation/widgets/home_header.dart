import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// Greeting + question on the start side, avatar on the end side. The order
/// is deliberate: [Row] lays children start-to-end, and under the app's RTL
/// Arabic layout "start" is the right edge — so text-first/avatar-last is
/// what puts the avatar on the physical left without hardcoding a side.
///
/// TODO: pull the display name and greeting (morning/evening) from the
/// authenticated user once auth is wired up — [Strings.homeGreeting] is a
/// static placeholder for now.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

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
                Strings.homeGreeting,
                style: AppTextStyles.body(color: c.textSecondary),
              ),
              SizedBox(height: AppSpacing.xxs.h),
              Text(
                Strings.homeQuestion,
                style: AppTextStyles.h1(color: c.textPrimary),
              ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.sm.w),
        Container(
          width: 44.r,
          height: 44.r,
          decoration: BoxDecoration(
            color: c.primary,
            borderRadius: BorderRadius.circular(AppRadius.md.r),
          ),
          child: const Icon(Icons.person_outline, color: Colors.white),
        ),
      ],
    );
  }
}
