import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../screens/forgot_password_screen.dart';

/// Back arrow, title and explanation at the top of each recovery step.
class ForgotPasswordStepHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const ForgotPasswordStepHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: const BackButtonIcon(),
            color: context.colors.textPrimary,
            onPressed: () => ForgotPasswordScreen.goBack(context),
          ),
        ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.h1(color: context.colors.textPrimary),
        ),
        SizedBox(height: AppSpacing.xs.h),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.body(color: context.colors.textSecondary),
        ),
        SizedBox(height: AppSpacing.xxl.h),
      ],
    );
  }
}
