import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validator.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_outlined_button.dart';
import '../cubit/auth_cubit.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../widgets/auth_password_field.dart';
import '../../../../core/widgets/phone_field.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_state_listener.dart';
import '../widgets/auth_submit_button.dart';
import '../widgets/auth_toggle_link.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthCubit>().login(
      phone: _phoneController.text,
      password: _passwordController.text,
    );
  }

  /// Pushed by a sign-in gate, Register is pushed too, and its success pops
  /// back through here to the gate. As the app's entry screen, it replaces.
  Future<void> _openRegister() async {
    if (!context.canPop()) {
      context.goNamed(AppRoutes.registerName);
      return;
    }
    final bool? registered = await context.pushNamed<bool>(
      AppRoutes.registerName,
    );
    if (registered == true && mounted) context.pop(true);
  }

  /// Browsing needs no account (App Store guideline 5.1.1(v)). Pushed by a
  /// sign-in gate, this just closes Login and leaves the guest where they
  /// were; otherwise (after a logout) it enters Home as a guest.
  void _continueAsGuest() {
    if (context.canPop()) {
      context.pop(false);
    } else {
      context.goNamed(AppRoutes.homeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthStateListener(
      child: AuthScaffold(
        child: Form(
          key: _formKey,
          child: AutofillGroup(
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
                  style: AppTextStyles.body(
                    color: context.colors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.xxl.h),
                LabeledField(
                  label: Strings.authPhoneLabel,
                  child: PhoneField(controller: _phoneController),
                ),
                SizedBox(height: AppSpacing.lg.h),
                LabeledField(
                  label: Strings.authPasswordLabel,
                  child: AuthPasswordField(
                    controller: _passwordController,
                    hintText: Strings.authPasswordHint,
                    // Presence only — never enforce today's length rule on
                    // sign-in, older accounts may predate it.
                    validator: (String? value) => Validator.call(
                      value: value,
                      type: ValidatorType.standard,
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () =>
                        context.pushNamed(AppRoutes.forgotPasswordName),
                    style: TextButton.styleFrom(
                      foregroundColor: context.colors.secondary,
                    ),
                    child: Text(Strings.authForgotPasswordLink),
                  ),
                ),
                SizedBox(height: AppSpacing.md.h),
                AuthSubmitButton(
                  label: Strings.authLoginButton,
                  onPressed: _submit,
                ),
                SizedBox(height: AppSpacing.lg.h),
                AuthToggleLink(
                  question: Strings.authNoAccount,
                  action: Strings.authCreateAccountLink,
                  onTap: _openRegister,
                ),
                SizedBox(height: AppSpacing.lg.h),
                AppOutlinedButton(
                  text: Strings.authContinueAsGuest,
                  onPressed: _continueAsGuest,
                ),
                SizedBox(height: AppSpacing.xl.h),
                Text(
                  Strings.authTermsNotice,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption(color: context.colors.textHint),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
