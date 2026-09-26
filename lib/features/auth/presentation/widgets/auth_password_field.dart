import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// Obscured password input with a show/hide toggle. The toggle is purely
/// local UI state, so `setState` here only rebuilds this field.
class AuthPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final FormFieldValidator<String>? validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  /// [AutofillHints.password] on login, [AutofillHints.newPassword] on sign-up
  /// so the OS offers to generate and save one.
  final String autofillHint;

  const AuthPasswordField({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.autofillHint = AutofillHints.password,
  });

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscured,
      enableSuggestions: false,
      autocorrect: false,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      autofillHints: <String>[widget.autofillHint],
      validator: widget.validator,
      onFieldSubmitted: widget.onSubmitted,
      style: AppTextStyles.bodyLarge(color: context.colors.textPrimary),
      decoration: InputDecoration(
        hintText: widget.hintText,
        suffixIcon: IconButton(
          tooltip: _obscured
              ? Strings.authShowPassword
              : Strings.authHidePassword,
          icon: Icon(
            _obscured
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => _obscured = !_obscured),
        ),
      ),
    );
  }
}
