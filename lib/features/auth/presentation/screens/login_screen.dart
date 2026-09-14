import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../widgets/auth_phone_field.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_toggle_link.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    // TODO: wire to AuthCubit.sendOtp(_phoneController.text) once the auth
    // API contract exists. For now this proves the screen and the flow.
    context.goNamed(AppRoutes.homeName);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            Strings.authWelcomeTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.h1(color: context.colors.textPrimary),
          ),
          SizedBox(height: AppSpacing.xs.h),
          Text(
            Strings.authWelcomeSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(color: context.colors.textSecondary),
          ),
          SizedBox(height: AppSpacing.xxl.h),
          Text(
            Strings.authPhoneLabel,
            style: AppTextStyles.body(color: context.colors.textSecondary),
          ),
          SizedBox(height: AppSpacing.xs.h),
          AuthPhoneField(controller: _phoneController),
          SizedBox(height: AppSpacing.xl.h),
          AppButton(btnText: Strings.authContinue, onPressed: _submit),
          SizedBox(height: AppSpacing.lg.h),
          AuthToggleLink(
            question: Strings.authNoAccount,
            action: Strings.authCreateAccountLink,
            onTap: () => context.goNamed(AppRoutes.registerName),
          ),
          SizedBox(height: AppSpacing.xl.h),
          Text(
            Strings.authTermsNotice,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(color: context.colors.textHint),
          ),
        ],
      ),
    );
  }
}
