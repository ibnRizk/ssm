import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/saudi_phone.dart';
import '../../../../core/utils/values/strings.dart';

/// Phone number entry with the Saudi country code fixed at the start of the
/// field — matches every phone input in the design (login, register,
/// pharmacy/parcel requests, …).
///
/// The `+966` prefix and the field share one bordered box rather than the
/// app's default `InputDecorationTheme` border, so the divider between them
/// reads as one control instead of two. It still takes part in the enclosing
/// [Form]: the box turns red and the error sits below it, like any
/// `TextFormField`.
class AuthPhoneField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputAction textInputAction;

  const AuthPhoneField({
    super.key,
    required this.controller,
    this.textInputAction = TextInputAction.next,
  });

  /// `05X XXX XXXX` has 10 digits — the longest local form accepted.
  static const int _maxDigits = 10;

  static String? _validate(String value) {
    if (value.trim().isEmpty) return Strings.fieldRequired;
    if (!SaudiPhone.isValid(value)) return Strings.invalidPhone;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: (_) => _validate(controller.text),
      builder: (FormFieldState<String> field) {
        final Color borderColor = field.hasError
            ? context.colors.error
            : context.colors.border;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: AppSizes.buttonHeight.h,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg.r),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: <Widget>[
                  Text(
                    SaudiPhone.countryCode,
                    style: AppTextStyles.bodyLarge(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm.w),
                  Container(width: 1, height: 22.h, color: borderColor),
                  SizedBox(width: AppSpacing.sm.w),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.phone,
                      textInputAction: textInputAction,
                      autofillHints: const <String>[
                        AutofillHints.telephoneNumberNational,
                      ],
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(_maxDigits),
                      ],
                      style: AppTextStyles.bodyLarge(
                        color: context.colors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: '05X XXX XXXX',
                        hintStyle: AppTextStyles.bodyLarge(
                          color: context.colors.textHint,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (field.errorText case final String error)
              Padding(
                padding: EdgeInsetsDirectional.only(
                  start: AppSpacing.md.w,
                  top: AppSpacing.xs.h,
                ),
                child: Text(
                  error,
                  style: AppTextStyles.caption(color: context.colors.error),
                ),
              ),
          ],
        );
      },
    );
  }
}
