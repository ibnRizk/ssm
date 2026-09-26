import 'dart:math';

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(
    RegExp(' +'),
    ' ',
  ).split(' ').map((str) => str.toCapitalized()).join(' ');
}

final RegExp _whitespaceRun = RegExp(r'\s+');

extension StringWhitespaceExtension on String {
  /// Trims and collapses inner runs of whitespace to one space — how a
  /// typed full name is sent to the API ("  Sara   Customer " → "Sara
  /// Customer").
  String collapseWhitespace() => trim().replaceAll(_whitespaceRun, ' ');
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

extension RoundOnlyDouble on double {
  double mRoundDouble(int places) {
    num mod = pow(10.0, places);
    return ((this * mod).round().toDouble() / mod);
  }
}
