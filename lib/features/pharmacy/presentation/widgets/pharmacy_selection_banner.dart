import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// The pastel-green "choose a pharmacy" prompt at the top of the order form.
/// Once one is chosen, [selectedName] replaces the prompt's subtitle.
class PharmacySelectionBanner extends StatelessWidget {
  final String? selectedName;
  final VoidCallback? onTap;

  const PharmacySelectionBanner({super.key, this.selectedName, this.onTap});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final String? name = selectedName;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.md.r),
        decoration: BoxDecoration(
          color: c.successLight,
          borderRadius: BorderRadius.circular(AppRadius.lg.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  Strings.pharmacySelectTitle,
                  style: AppTextStyles.titleSmall(color: c.success),
                ),
                SizedBox(width: AppSpacing.xs.w),
                Icon(
                  name == null ? Icons.add : Icons.edit_outlined,
                  color: c.success,
                  size: 18.r,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xxs.h),
            Text(
              name ?? Strings.pharmacySelectSubtitle,
              style: name == null
                  ? AppTextStyles.caption(color: c.textSecondary)
                  : AppTextStyles.body(color: c.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
