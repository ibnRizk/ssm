import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Caption above an input — the label style every auth field shares.
class AuthLabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const AuthLabeledField({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          style: AppTextStyles.body(color: context.colors.textSecondary),
        ),
        SizedBox(height: AppSpacing.xs.h),
        child,
      ],
    );
  }
}
