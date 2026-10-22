import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/number_input.dart';
import '../utils/saudi_phone.dart';
import '../utils/values/strings.dart';

/// An [TextInputFormatter] that silently converts Eastern-Arabic (٠–٩) and
/// Persian (۰–۹) digits to their Western equivalents (0–9) on every
/// keystroke. All other characters — including '+' for the international
/// prefix — are passed through unchanged.
class ArabicToLatinInputFormatter extends TextInputFormatter {
  const ArabicToLatinInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String normalized = NumberInput.normalizeDigits(newValue.text);
    if (normalized == newValue.text) return newValue;

    // Normalisation is always 1-to-1 (one Arabic digit → one Latin digit),
    // so character counts never change and the cursor offset is stable.
    return newValue.copyWith(
      text: normalized,
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }
}

/// Phone number entry for Saudi mobile numbers.
///
/// Accepted formats (C2C backend contract):
///   • `05XXXXXXXX`    — 10 digits  (local Saudi)
///   • `9665XXXXXXXX`  — 12 digits  (international without +)
///   • `+9665XXXXXXXX` — 13 chars   (E.164 with leading +)
///
/// Arabic/Persian digits (٠–٩ / ۰–۹) are normalised to Latin digits as
/// the user types, so they are transparent both on screen and to validation.
///
/// The field is LTR so that '+' and digit sequences always read left-to-right
/// regardless of the app locale.
class PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputAction textInputAction;

  const PhoneField({
    super.key,
    required this.controller,
    this.textInputAction = TextInputAction.next,
  });

  /// Maximum character count: `+9665XXXXXXXX` = 13.
  static const int _maxLength = 13;

  static String? _validate(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return Strings.fieldRequired;
    // SaudiPhone.isValid also normalises Arabic/Persian digits internally.
    if (!SaudiPhone.isValid(trimmed)) return Strings.invalidPhone;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.start,
      textInputAction: textInputAction,
      autofillHints: const <String>[
        AutofillHints.telephoneNumber,
      ],
      inputFormatters: <TextInputFormatter>[
        // 1. Normalise ٠–٩ / ۰–۹ → 0–9 as the user types.
        const ArabicToLatinInputFormatter(),
        // 2. Allow digits and a leading '+' only — no letters, no spaces.
        FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
        // 3. Hard cap at 13 characters (+9665XXXXXXXX).
        LengthLimitingTextInputFormatter(_maxLength),
      ],
      style: AppTextStyles.bodyLarge(
        color: context.colors.textPrimary,
      ),
      validator: (String? value) => _validate(value ?? ''),
      decoration: const InputDecoration(
        hintText: '05XXXXXXXXX / +9665XXXXXXXX',
      ),
    );
  }
}

