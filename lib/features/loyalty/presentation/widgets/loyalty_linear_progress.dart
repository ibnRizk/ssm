import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// "Completed orders" label + percentage, with a thin rounded bar below it.
/// A [Stack]/[FractionallySizedBox] pair, not [LinearProgressIndicator]:
/// the latter's corner rounding is inconsistent across platforms, and this
/// gives exact control to match the design's fully-rounded track and fill.
class LoyaltyLinearProgress extends StatelessWidget {
  final double progress;

  const LoyaltyLinearProgress({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final double clamped = progress.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              '${(clamped * 100).round()}%',
              style: AppTextStyles.titleSmall(color: c.secondary),
            ),
            const Spacer(),
            Text(
              Strings.loyaltyCompletedOrdersLabel,
              style: AppTextStyles.body(color: c.textSecondary),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xs.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: SizedBox(
            height: 8.h,
            child: Stack(
              children: <Widget>[
                Container(color: c.border),
                FractionallySizedBox(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: clamped,
                  child: Container(color: c.secondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
