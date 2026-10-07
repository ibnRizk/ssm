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
import '../cubit/auth_cubit.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../widgets/auth_password_field.dart';
import '../../../../core/widgets/phone_field.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_state_listener.dart';
import '../widgets/auth_submit_button.dart';
import '../widgets/auth_toggle_link.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    context.read<AuthCubit>().register(
      name: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle inputStyle = AppTextStyles.bodyLarge(
      color: context.colors.textPrimary,
    );

    return AuthStateListener(
      child: AuthScaffold(
        child: Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  Strings.authRegisterTitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h1(
                    color: context.colors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.xs.h),
                Text(
                  Strings.authRegisterSubtitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(
                    color: context.colors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.xxl.h),
                LabeledField(
                  label: Strings.authFullNameLabel,
                  child: TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    textCapitalization:
                        TextCapitalization.words,
                    autofillHints: const <String>[
                      AutofillHints.name,
                    ],
                    style: inputStyle,
                    decoration: InputDecoration(
                      hintText: Strings.authFullNameHint,
                    ),
                    // The API takes one `name` field — require first + last.
                    validator: (String? value) =>
                        Validator.call(
                          value: value,
                          type: ValidatorType.name,
                        ),
                  ),
                ),
                SizedBox(height: AppSpacing.lg.h),
                LabeledField(
                  label: Strings.authPhoneLabel,
                  child: PhoneField(
                    controller: _phoneController,
                  ),
                ),
                SizedBox(height: AppSpacing.lg.h),
                LabeledField(
                  label: Strings.authEmailLabel,
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType:
                        TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    autofillHints: const <String>[
                      AutofillHints.email,
                    ],
                    style: inputStyle,
                    decoration: InputDecoration(
                      hintText: Strings.authEmailHint,
                    ),
                    validator: (String? value) =>
                        Validator.call(
                          value: value?.trim(),
                          type: ValidatorType.email,
                        ),
                  ),
                ),
                SizedBox(height: AppSpacing.lg.h),
                LabeledField(
                  label: Strings.authPasswordLabel,
                  child: AuthPasswordField(
                    controller: _passwordController,
                    hintText: Strings.authNewPasswordHint,
                    autofillHint: AutofillHints.newPassword,
                    validator: (String? value) =>
                        Validator.call(
                          value: value,
                          type: ValidatorType.password,
                        ),
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                SizedBox(height: AppSpacing.xl.h),
                AuthSubmitButton(
                  label: Strings.authRegisterButton,
                  onPressed: _submit,
                ),
                SizedBox(height: AppSpacing.lg.h),
                AuthToggleLink(
                  question: Strings.authHaveAccount,
                  action: Strings.authLoginLink,
                  onTap: () =>
                      context.goNamed(AppRoutes.loginName),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
