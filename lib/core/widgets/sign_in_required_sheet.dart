import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_dimens.dart';
import '../utils/values/strings.dart';
import 'app_button.dart';
import 'app_outlined_button.dart';
import 'modal_bottom_sheet_scaffold.dart';

/// "Please sign in to use this" — shown when a guest opens an account-based
/// feature. Pops `true` for "Sign in", `false` for "Not now".
///
/// Use `ensureSignedIn` (core/session) rather than showing it directly.
class SignInRequiredSheet extends StatelessWidget {
  const SignInRequiredSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return ModalBottomSheetScaffold(
      title: Strings.signInRequiredTitle,
      subTitle: Strings.signInRequiredMessage,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.lg.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AppButton(
                btnText: Strings.authLoginButton,
                onPressed: () => Navigator.pop(context, true),
              ),
              SizedBox(height: AppSpacing.sm.h),
              AppOutlinedButton(
                text: Strings.notNow,
                onPressed: () => Navigator.pop(context, false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
