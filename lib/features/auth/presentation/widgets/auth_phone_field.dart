import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Phone number entry with the Saudi country code fixed at the start of the
/// field — matches every phone input in the design (login, register,
/// pharmacy/parcel requests, …).
///
/// The `+966` prefix and the field share one bordered box rather than the
/// app's default `InputDecorationTheme` border, so the divider between them
/// reads as one control instead of two.
class AuthPhoneField extends StatelessWidget {
  final TextEditingController controller;

  const AuthPhoneField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.buttonHeight.h,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: <Widget>[
          Text(
            '+966',
            style: AppTextStyles.bodyLarge(color: context.colors.textPrimary),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Container(width: 1, height: 22.h, color: context.colors.border),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              style: AppTextStyles.bodyLarge(color: context.colors.textPrimary),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: '05X XXX XXXX',
                hintStyle: AppTextStyles.bodyLarge(
                  color: context.colors.textHint,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
