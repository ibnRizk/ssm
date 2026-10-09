import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// The entry to door-to-door parcels: a navy gradient card with the pitch
/// and one orange call to action. The whole card is tappable.
class C2cSendParcelCard extends StatelessWidget {
  final VoidCallback onSend;

  const C2cSendParcelCard({super.key, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final BorderRadius radius = BorderRadius.circular(AppRadius.xl.r);
    return Material(
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: <Color>[c.primary, c.primaryDark],
          ),
        ),
        child: InkWell(
          onTap: onSend,
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 64.r,
                  height: 64.r,
                  decoration: BoxDecoration(
                    color: c.secondary,
                    borderRadius: BorderRadius.circular(AppRadius.lg.r),
                  ),
                  child: Icon(
                    Icons.inventory_2_rounded,
                    color: Colors.white,
                    size: 32.r,
                  ),
                ),
                SizedBox(height: AppSpacing.lg.h),
                Text(
                  Strings.c2cHeroTitle,
                  style: AppTextStyles.h1(color: Colors.white),
                ),
                SizedBox(height: AppSpacing.xs.h),
                Text(
                  Strings.c2cHeroSubtitle,
                  style: AppTextStyles.body(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                SizedBox(height: AppSpacing.xl.h),
                // Decorative: the card itself is the tap target, so this
                // stays out of the semantics tree to avoid a double button.
                ExcludeSemantics(
                  child: Container(
                    height: AppSizes.buttonHeight.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.secondary,
                      borderRadius: BorderRadius.circular(AppRadius.lg.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.send_rounded,
                          size: 18.r,
                          color: Colors.white,
                        ),
                        SizedBox(width: AppSpacing.xs.w),
                        Text(
                          Strings.c2cHeroButton,
                          style: AppTextStyles.button(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
