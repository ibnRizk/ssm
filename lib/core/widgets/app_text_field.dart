// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '/core/utils/validator.dart';
import '../../injection_container.dart';

class MyTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValidatorType? validatorType;
  final Function()? onTap;
  final String? labelText;
  final String? hintText;
  final int? maxLines;
  final int? minLines;
  final double? radius;
  final String? Function(String?)? validator;
  final Function(String? val)? onSaved;
  final Function(String? val)? onChanged;
  final Function(String val)? onSubmit;
  final bool obscureText;
  final Widget? suffix;
  final Widget? prefixWidget;
  final IconData? prefix;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool? isPhone;
  final bool? isEdit;
  final bool readOnly;
  final TextInputType? keyboardType;
  final bool arLang;
  final TextInputAction? textInputAction;
  final TextAlign textAlign;
  final Color? backgroundColor;
  final List<TextInputFormatter>? inputFormatters;
  final Color? borderColor;

  const MyTextFormField({
    super.key,
    required this.controller,
    this.focusNode,
    this.validatorType,
    this.validator,
    required this.hintText,
    this.onSaved,
    this.onChanged,
    this.onSubmit,
    this.textAlign = TextAlign.start,
    this.labelText,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.prefix,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixWidget,
    this.isPhone = false,
    this.isEdit = false,
    this.maxLines,
    this.minLines,
    this.readOnly = false,
    this.onTap,
    this.arLang = false,
    this.textInputAction,
    this.backgroundColor,
    this.inputFormatters,
    this.radius,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    final double myFontSize = 12.sp;
    final bool isFocused = focusNode?.hasFocus ?? false;

    final Color effectiveColor = labelText != null
        ? colors.textPrimary
        : isFocused
        ? colors.textPrimary
        : colors.textPrimary.withOpacity(0.5);

    final Color labelColor = isFocused ? colors.primary : colors.textPrimary;

    return TextFormField(
      controller: controller,
      maxLines: maxLines ?? 1,
      minLines: minLines,
      textDirection: arLang ? TextDirection.rtl : null,
      keyboardType: keyboardType,
      textInputAction: textInputAction ?? TextInputAction.done,
      validator: validatorType != null
          ? (String? value) =>
                Validator.call(value: value, type: validatorType!)
          : validator,
      readOnly: readOnly,
      textAlign: textAlign,
      obscureText: obscureText,
      cursorColor: colors.textPrimary,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        suffix: suffix,
        prefix: isPhone == true
            ? prefixWidget
            : prefix != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Icon(prefix, size: 16, color: Colors.grey),
              )
            : null,
        fillColor: backgroundColor ?? colors.primary,
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius ?? 12.r)),
          borderSide: BorderSide(
            color: borderColor ?? Color(0xFFF2F2F2), //todo
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius ?? 12.r)),
          borderSide: BorderSide(
            color: borderColor ?? colors.primary,
            width: 2.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius ?? 12.r)),
          borderSide: BorderSide(color: colors.error, width: 1.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius ?? 12.r)),
          borderSide: BorderSide(color: colors.error, width: 1.0),
        ),
        floatingLabelBehavior: labelText != null
            ? FloatingLabelBehavior.auto
            : FloatingLabelBehavior.never,
        hintText: hintText,
        labelText: labelText,
        errorMaxLines: 2,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        labelStyle: theme.bodyMedium!.copyWith(
          color: labelColor,
          fontSize: myFontSize,
        ),
        errorStyle: theme.bodySmall!.copyWith(
          color: Colors.red,
          fontSize: myFontSize - 4,
        ),
        hintStyle: theme.bodyMedium!.copyWith(
          color: Colors.grey,
          fontSize: myFontSize,
        ),
      ),
      style: theme.bodyMedium!.copyWith(
        color: effectiveColor,
        fontSize: myFontSize,
      ),
      focusNode: focusNode,
      onSaved: onSaved,
      onTap: onTap,
      onChanged: onChanged,
      onFieldSubmitted: onSubmit,
      onTapOutside: (_) {
        FocusScope.of(context).unfocus();
      },
    );
  }
}
