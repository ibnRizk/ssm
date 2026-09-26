import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/saudi_phone.dart';
import '../../../../core/utils/validator.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/phone_field.dart';
import '../../domain/entities/customer_profile.dart';
import '../cubit/edit_profile_cubit.dart';
import '../cubit/edit_profile_state.dart';
import '../cubit/profile_cubit.dart';

/// Name / phone / email, pre-filled from [initial]. On a successful save it
/// pushes the new profile into [ProfileCubit] and pops back to Account.
class EditProfileForm extends StatefulWidget {
  final CustomerProfile initial;

  const EditProfileForm({super.key, required this.initial});

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initial.name);
    // The field has a fixed +966 prefix, so it holds the local form.
    _phoneController = TextEditingController(
      text: SaudiPhone.toLocal(widget.initial.phone),
    );
    _emailController = TextEditingController(text: widget.initial.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<EditProfileCubit>().submit(
      current: widget.initial,
      name: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
    );
  }

  void _onStateChanged(BuildContext context, EditProfileState state) {
    switch (state) {
      case EditProfileSuccess(:final profile):
        context.read<ProfileCubit>().profileUpdated(profile);
        showAppSnackBar(
          context: context,
          message: Strings.editProfileSuccess,
          type: ToastType.success,
        );
        context.pop();
      case EditProfileError(:final failure):
        showAppSnackBar(
          context: context,
          message: failure.userMessage,
          type: ToastType.error,
        );
      case EditProfileInitial() || EditProfileSubmitting():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle inputStyle = AppTextStyles.bodyLarge(
      color: context.colors.textPrimary,
    );

    return BlocListener<EditProfileCubit, EditProfileState>(
      listener: _onStateChanged,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screen.w,
          AppSpacing.lg.h,
          AppSpacing.screen.w,
          AppSpacing.xxl.h,
        ),
        child: Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                LabeledField(
                  label: Strings.authFullNameLabel,
                  child: TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const <String>[AutofillHints.name],
                    style: inputStyle,
                    decoration: InputDecoration(
                      hintText: Strings.authFullNameHint,
                    ),
                    // The API takes one `name` field — require first + last.
                    validator: (String? value) =>
                        Validator.call(value: value, type: ValidatorType.name),
                  ),
                ),
                SizedBox(height: AppSpacing.lg.h),
                LabeledField(
                  label: Strings.authPhoneLabel,
                  child: PhoneField(controller: _phoneController),
                ),
                SizedBox(height: AppSpacing.lg.h),
                LabeledField(
                  label: Strings.authEmailLabel,
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    autofillHints: const <String>[AutofillHints.email],
                    style: inputStyle,
                    decoration: InputDecoration(
                      hintText: Strings.authEmailHint,
                    ),
                    validator: (String? value) => Validator.call(
                      value: value?.trim(),
                      type: ValidatorType.email,
                    ),
                    onFieldSubmitted: (_) => _submit(),
                  ),
                ),
                SizedBox(height: AppSpacing.xl.h),
                // Only the button rebuilds while the request runs.
                BlocSelector<EditProfileCubit, EditProfileState, bool>(
                  selector: (EditProfileState state) =>
                      state is EditProfileSubmitting,
                  builder: (BuildContext context, bool isSubmitting) =>
                      AppButton(
                        btnText: Strings.save,
                        isLoading: isSubmitting,
                        onPressed: _submit,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
