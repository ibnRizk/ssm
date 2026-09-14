import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// The dark navy hero card: heading, a thick circular progress ring with the
/// count inside it, and a "N orders left" line with the count highlighted
/// orange. The two faint decorative circles echo [AuthScaffold]'s same
/// subtle-curves-on-navy treatment.
class LoyaltyProgressCard extends StatelessWidget {
  final int completed;
  final int target;

  const LoyaltyProgressCard({
    super.key,
    required this.completed,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final double progress = (completed / target).clamp(0.0, 1.0);
    final int remaining = (target - completed).clamp(0, target);

    final List<String> templateParts = Strings.loyaltyRemainingOrdersTemplate
        .split('{count}');
    final String remainingFragment =
        '$remaining ${Strings.loyaltyOrdersUnit}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl.r),
      child: Container(
        width: double.infinity,
        color: c.primary,
        padding: EdgeInsets.all(AppSpacing.lg.r),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned(
              top: -40.r,
              right: -40.r,
              child: _DecorativeCircle(size: 140.r),
            ),
            Positioned(
              bottom: -50.r,
              left: -50.r,
              child: _DecorativeCircle(size: 160.r),
            ),
            Column(
              children: <Widget>[
                Text(
                  Strings.loyaltyProgressHeading,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(color: Colors.white),
                ),
                SizedBox(height: AppSpacing.lg.h),
                SizedBox(
                  width: 160.r,
                  height: 160.r,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 12.r,
                          backgroundColor: c.primaryDark,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            c.secondary,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            '$completed',
                            style: AppTextStyles.display(color: Colors.white),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            Strings.loyaltyProgressOfLabel(target),
                            style: AppTextStyles.caption(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.lg.h),
                Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(text: templateParts.first),
                      TextSpan(
                        text: remainingFragment,
                        style: AppTextStyles.titleSmall(color: c.secondary),
                      ),
                      if (templateParts.length > 1)
                        TextSpan(text: templateParts[1]),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleSmall(color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  final double size;

  const _DecorativeCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.06),
      ),
    );
  }
}
