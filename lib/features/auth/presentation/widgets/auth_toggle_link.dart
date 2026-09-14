import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// `"<question> <action>"` footer — flips between Login and Register.
class AuthToggleLink extends StatelessWidget {
  final String question;
  final String action;
  final VoidCallback onTap;

  const AuthToggleLink({
    super.key,
    required this.question,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4.w,
        children: <Widget>[
          Text(
            question,
            style: AppTextStyles.body(color: context.colors.textSecondary),
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              action,
              style: AppTextStyles.titleSmall(color: context.colors.secondary),
            ),
          ),
        ],
      ),
    );
  }
}
