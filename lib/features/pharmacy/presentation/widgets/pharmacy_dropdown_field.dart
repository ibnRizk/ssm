import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// A dropdown-styled selector. [label] is the current value; tapping it will
/// open the real picker once the pharmacy catalog exists (TODO below).
class PharmacyDropdownField extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const PharmacyDropdownField({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSizes.buttonHeight.h,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg.r),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyLarge(color: c.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: c.textSecondary,
              size: AppSizes.icon.r,
            ),
          ],
        ),
      ),
    );
  }
}
