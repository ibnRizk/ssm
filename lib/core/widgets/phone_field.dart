import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/saudi_phone.dart';
import '../utils/values/strings.dart';

/// Phone number entry with the Saudi country code fixed at the start of the
/// field — matches every phone input in the design (login, register,
/// pharmacy/parcel requests, …).
/// The `+966` prefix and the field share one bordered box rather than the
/// app's default `InputDecorationTheme` border, so the divider between them
/// reads as one control instead of two. It still takes part in the enclosing
/// [Form]: the box turns red and the error sits below it, like any
/// `TextFormField`.
class PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputAction textInputAction;

  const PhoneField({
    super.key,
    required this.controller,
    this.textInputAction = TextInputAction.next,
  });

  /// `05X XXX XXXX` has 10 digits — the longest local form accepted.
  static const int _maxDigits = 10;

  static String? _validate(String value) {
    if (value.trim().isEmpty) return Strings.fieldRequired;
    if (!SaudiPhone.isValid(value)) {
      return Strings.invalidPhone;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
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
      validator: (String? value) => _validate(value ?? ''),
      decoration: InputDecoration(hintText: '05X XXX XXXX'),
    );
  }
}
