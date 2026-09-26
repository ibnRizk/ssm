import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// Search affordance — opens the stores screen, where the search runs.
class HomeSearchField extends StatelessWidget {
  const HomeSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return GestureDetector(
      onTap: () => context.push(AppRoutes.restaurants),
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.search, color: c.textSecondary, size: AppSizes.icon.r),
            SizedBox(width: AppSpacing.sm.w),
            Expanded(
              child: Text(
                Strings.homeSearchHint,
                style: AppTextStyles.body(color: c.textHint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
