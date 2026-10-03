import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/validator.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../cubit/forgot_password_cubit.dart';
import 'auth_password_field.dart';
import 'forgot_password_step_header.dart';
import 'forgot_password_submit_button.dart';

/// Step 3: the new password, entered twice.
class ForgotPasswordNewPasswordStep extends StatefulWidget {
  const ForgotPasswordNewPasswordStep({super.key});

  @override
  State<ForgotPasswordNewPasswordStep> createState() =>
      _ForgotPasswordNewPasswordStepState();
}

class _ForgotPasswordNewPasswordStepState
    extends State<ForgotPasswordNewPasswordStep> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmController;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateConfirmation(String? value) {
    if (value == null || value.isEmpty) return Strings.fieldRequired;
    if (value != _passwordController.text) return Strings.passwordsDoNotMatch;
    return null;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<ForgotPasswordCubit>().resetPassword(_passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ForgotPasswordStepHeader(
              title: Strings.forgotPasswordNewTitle,
              subtitle: Strings.forgotPasswordNewSubtitle,
            ),
            LabeledField(
              label: Strings.authPasswordLabel,
              child: AuthPasswordField(
                controller: _passwordController,
                hintText: Strings.authNewPasswordHint,
                autofillHint: AutofillHints.newPassword,
                textInputAction: TextInputAction.next,
                // Same rule as sign-up: at least 8 characters.
                validator: (String? value) =>
                    Validator.call(value: value, type: ValidatorType.password),
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),
            LabeledField(
              label: Strings.forgotPasswordConfirmLabel,
              child: AuthPasswordField(
                controller: _confirmController,
                hintText: Strings.authNewPasswordHint,
                autofillHint: AutofillHints.newPassword,
                validator: _validateConfirmation,
                onSubmitted: (_) => _submit(),
              ),
            ),
            SizedBox(height: AppSpacing.xl.h),
            ForgotPasswordSubmitButton(
              label: Strings.forgotPasswordSaveButton,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
