import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/saudi_phone.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';
import 'forgot_password_step_header.dart';
import 'forgot_password_submit_button.dart';

/// Step 2: the one-time code texted to [phone].
class ForgotPasswordCodeStep extends StatefulWidget {
  /// E.164 — shown in the local form.
  final String phone;

  const ForgotPasswordCodeStep({super.key, required this.phone});

  @override
  State<ForgotPasswordCodeStep> createState() => _ForgotPasswordCodeStepState();
}

class _ForgotPasswordCodeStepState extends State<ForgotPasswordCodeStep> {
  /// The backend's codes are 4 to 6 digits, depending on its settings.
  static const int _minDigits = 4;
  static const int _maxDigits = 6;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  static String? _validate(String? value) {
    final int length = value?.trim().length ?? 0;
    if (length == 0) return Strings.fieldRequired;
    if (length < _minDigits) return Strings.forgotPasswordInvalidCode;
    return null;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<ForgotPasswordCubit>().verifyCode(_codeController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ForgotPasswordStepHeader(
            title: Strings.forgotPasswordCodeTitle,
            subtitle: Strings.forgotPasswordCodeSubtitle(
              SaudiPhone.toLocal(widget.phone),
            ),
          ),
          LabeledField(
            label: Strings.forgotPasswordCodeLabel,
            child: TextFormField(
              controller: _codeController,
              autofocus: true,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              textAlign: TextAlign.center,
              autofillHints: const <String>[AutofillHints.oneTimeCode],
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(_maxDigits),
              ],
              style: AppTextStyles.h2(color: context.colors.textPrimary),
              decoration: const InputDecoration(hintText: '• • • •'),
              validator: _validate,
              onFieldSubmitted: (_) => _submit(),
            ),
          ),
          SizedBox(height: AppSpacing.xl.h),
          ForgotPasswordSubmitButton(
            label: Strings.forgotPasswordVerifyButton,
            onPressed: _submit,
          ),
          SizedBox(height: AppSpacing.md.h),
          const _ResendButton(),
        ],
      ),
    );
  }
}

class _ResendButton extends StatelessWidget {
  const _ResendButton();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ForgotPasswordCubit, ForgotPasswordState, bool>(
      selector: (ForgotPasswordState state) => state.isSubmitting,
      builder: (BuildContext context, bool isSubmitting) => Center(
        child: TextButton(
          onPressed: isSubmitting
              ? null
              : () => context.read<ForgotPasswordCubit>().resendCode(),
          style: TextButton.styleFrom(
            foregroundColor: context.colors.secondary,
          ),
          child: Text(Strings.forgotPasswordResend),
        ),
      ),
    );
  }
}
