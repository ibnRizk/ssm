/// Saudi mobile numbers. The UI fixes the `+966` prefix, so customers type
/// the local form (`05X XXX XXXX`); the backend stores E.164 (`+9665…`).
abstract class SaudiPhone {
  static const String countryCode = '+966';

  static final RegExp _nonDigits = RegExp(r'\D');
  static final RegExp _nationalMobile = RegExp(r'^5\d{8}$');

  /// The 9-digit national number (`5XXXXXXXX`), whether [input] was typed as
  /// `05…`, `5…`, `9665…`, `+9665…` or `009665…`, with any spacing.
  static String national(String input) {
    String digits = input.replaceAll(_nonDigits, '');
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
