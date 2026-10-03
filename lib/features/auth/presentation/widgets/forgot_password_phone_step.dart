import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/phone_field.dart';
import '../cubit/forgot_password_cubit.dart';
import 'forgot_password_step_header.dart';
import 'forgot_password_submit_button.dart';

/// Step 1: the registered phone number the code is texted to.
class ForgotPasswordPhoneStep extends StatefulWidget {
  /// Prefilled when coming back from the code step.
  final String initialPhone;

  const ForgotPasswordPhoneStep({super.key, this.initialPhone = ''});

  @override
  State<ForgotPasswordPhoneStep> createState() =>
      _ForgotPasswordPhoneStepState();
}

class _ForgotPasswordPhoneStepState extends State<ForgotPasswordPhoneStep> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<ForgotPasswordCubit>().requestCode(_phoneController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ForgotPasswordStepHeader(
            title: Strings.forgotPasswordTitle,
            subtitle: Strings.forgotPasswordPhoneSubtitle,
          ),
          LabeledField(
            label: Strings.authPhoneLabel,
            child: PhoneField(
              controller: _phoneController,
              textInputAction: TextInputAction.done,
            ),
          ),
          SizedBox(height: AppSpacing.xl.h),
          ForgotPasswordSubmitButton(
            label: Strings.forgotPasswordSendCode,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
