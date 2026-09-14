import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// The tall multiline "what do you need" field. Takes an externally-owned
/// [controller] — the screen creates and disposes it, this widget only
/// renders it, matching [AuthPhoneField]'s split of ownership.
class PharmacyRequestField extends StatelessWidget {
  final TextEditingController controller;

  const PharmacyRequestField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return TextField(
      controller: controller,
      minLines: 6,
      maxLines: 10,
      style: AppTextStyles.body(color: c.textPrimary),
      decoration: InputDecoration(
        filled: true,
        fillColor: c.surface,
        contentPadding: EdgeInsets.all(AppSpacing.md.r),
        hintText: Strings.pharmacyRequestHint,
        hintStyle: AppTextStyles.body(color: c.textHint),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg.r),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg.r),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg.r),
          borderSide: BorderSide(color: c.primary, width: 2),
        ),
      ),
    );
  }
}
