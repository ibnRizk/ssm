/// Reading numbers typed on any keyboard the app's users have: Western
/// (`0-9`), Eastern-Arabic (`٠-٩`, the Arabic keyboard) and Persian
/// (`۰-۹`, some Arabic layouts on Android).
abstract final class NumberInput {
  /// Every character an amount field may hold: the three digit sets, the
  /// Western and Arabic decimal separators (`.` `٫`) and the thousands
  /// separators (`,` `٬`). For a `FilteringTextInputFormatter.allow`.
  static final RegExp amountCharacters = RegExp('[0-9٠-٩۰-۹.٫,٬]');

  static final RegExp _amount = RegExp(r'^\d+(\.\d{1,2})?$');

  /// [input] with Eastern-Arabic and Persian digits as Western ones.
  static String normalizeDigits(String input) {
    final StringBuffer out = StringBuffer();
    for (final int rune in input.runes) {
      out.writeCharCode(switch (rune) {
        >= 0x0660 && <= 0x0669 => rune - 0x0660 + 0x30, // ٠-٩
        >= 0x06F0 && <= 0x06F9 => rune - 0x06F0 + 0x30, // ۰-۹
        _ => rune,
      });
    }
    return out.toString();
  }

  /// A non-negative amount with at most two decimals, or null when [input]
  /// is blank or isn't one. `,` and `٬` are thousands separators
  /// (`1,000` is one thousand, never `1.0`); `.` and `٫` the decimal one.
  static double? parseAmount(String input) {
    final String text = normalizeDigits(input.trim())
        .replaceAll(RegExp('[,٬\\s]'), '')
        .replaceAll('٫', '.');
    if (!_amount.hasMatch(text)) return null;
    return double.tryParse(text);
  }
}
