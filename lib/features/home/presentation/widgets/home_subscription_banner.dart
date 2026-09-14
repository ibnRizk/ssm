import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/brand_wave.dart';

/// The navy promo card: white title/subtitle on the start side, an amber
/// "خصم" badge on the end side, and the brand wave washing in from the
/// bottom. The wave is anchored to the card's physical bottom-left corner —
/// like the splash and auth screens' decorations, that's a fixed background
/// flourish, not content, so it doesn't mirror with locale.
class HomeSubscriptionBanner extends StatelessWidget {
  const HomeSubscriptionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl.r),
      child: Container(
        width: double.infinity,
        color: c.primary,
        padding: EdgeInsets.all(AppSpacing.lg.r),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: -AppSpacing.xl.r,
              right: -AppSpacing.xl.r,
              bottom: -AppSpacing.lg.r,
              height: 100.h,
              child: BrandWave(color: c.secondary),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: Text(
                    Strings.homeSubscriptionBadge,
                    style: AppTextStyles.titleSmall(color: c.accent),
                  ),
                ),
                SizedBox(height: AppSpacing.sm.h),
                FractionallySizedBox(
                  widthFactor: 0.62,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    Strings.homeSubscriptionTitle,
                    style: AppTextStyles.h2(color: Colors.white),
                  ),
                ),
                SizedBox(height: AppSpacing.xxs.h),
                FractionallySizedBox(
                  widthFactor: 0.62,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    Strings.homeSubscriptionSubtitle,
                    style: AppTextStyles.body(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
                SizedBox(height: 56.h), // reserves room for the wave below
              ],
            ),
          ],
        ),
      ),
    );
  }
}
