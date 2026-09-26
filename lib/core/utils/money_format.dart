import 'values/strings.dart';

/// `100` for whole amounts, `99.50` otherwise — how prices and cash-on-
/// delivery amounts are shown.
String formatAmount(double amount) => amount == amount.roundToDouble()
    ? amount.toStringAsFixed(0)
    : amount.toStringAsFixed(2);

/// Localized symbol for SAR; any other ISO code is shown as sent.
String currencySymbol(String code) =>
    code.toUpperCase() == 'SAR' ? Strings.currencySar : code;
