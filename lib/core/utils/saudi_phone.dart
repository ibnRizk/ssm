import 'number_input.dart';

/// Saudi mobile numbers accepted by the C2C backend:
///   • local   : `05XXXXXXXX`  (10 digits)
///   • E.164   : `9665XXXXXXXX` (12 digits) or `+9665XXXXXXXX` (13 chars)
///
/// All methods silently normalise Eastern-Arabic (`٠-٩`) and Persian (`۰-۹`)
/// digits to Western ones before processing, so callers never have to.
abstract class SaudiPhone {
  static const String countryCode = '+966';

  // Strips every character that isn't a Western digit after normalisation.
  static final RegExp _nonDigits = RegExp(r'\D');
  static final RegExp _nationalMobile = RegExp(r'^5\d{8}$');

  /// The 9-digit national number (`5XXXXXXXX`), whether [input] was typed as
  /// `05…`, `5…`, `9665…`, `+9665…` or `009665…`, with any spacing or
  /// Arabic/Persian digits.
  static String national(String input) {
    // Normalise ٠-٩ / ۰-۹ → 0-9, then drop everything that isn't a digit.
    String digits =
        NumberInput.normalizeDigits(input).replaceAll(_nonDigits, '');
    if (digits.startsWith('00966')) {
      digits = digits.substring(5);
    } else if (digits.startsWith('966')) {
      digits = digits.substring(3);
    }
    if (digits.startsWith('0')) digits = digits.substring(1);
    return digits;
  }

  static bool isValid(String input) =>
      _nationalMobile.hasMatch(national(input));

  static String toE164(String input) => '$countryCode${national(input)}';

  /// The form customers recognise (`05XXXXXXXX`). Anything that isn't a
  /// valid Saudi mobile is returned unchanged rather than mangled.
  static String toLocal(String input) =>
      isValid(input) ? '0${national(input)}' : input;
}
