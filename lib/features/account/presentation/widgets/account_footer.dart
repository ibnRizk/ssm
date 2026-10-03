import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// Centered app-name + tagline shown at the very bottom of the Account tab.
class AccountFooter extends StatelessWidget {
  const AccountFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Column(
      children: <Widget>[
        Text(
          Strings.appName,
          style: AppTextStyles.caption(color: c.textSecondary),
        ),
        SizedBox(height: 2.h),
        Text(
          Strings.accountFooterTagline,
          style: AppTextStyles.caption(color: c.textHint),
        ),
      ],
    );
  }
}
