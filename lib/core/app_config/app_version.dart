import 'package:equatable/equatable.dart';

/// A dotted version number (`1.4.2`), compared part by part, with missing
/// parts read as zero — so `1.4` equals `1.4.0`.
class AppVersion extends Equatable implements Comparable<AppVersion> {
  final List<int> parts;

  const AppVersion(this.parts);

  /// Accepts `1.4.2`, `v1.4` and `1.4.2+7` (the build number after `+` or a
  /// pre-release tag after `-` is ignored). Null for anything else.
  static AppVersion? tryParse(String value) {
    String text = value.trim();
    if (text.startsWith('v') || text.startsWith('V')) text = text.substring(1);
    text = text.split(RegExp('[+-]')).first;
    if (text.isEmpty) return null;
    final List<int> parts = <int>[];
    for (final String part in text.split('.')) {
      final int? number = int.tryParse(part);
      if (number == null || number < 0) return null;
      parts.add(number);
    }
    return AppVersion(List<int>.unmodifiable(parts));
  }

  @override
  int compareTo(AppVersion other) {
    final int length = parts.length > other.parts.length
        ? parts.length
        : other.parts.length;
    for (int i = 0; i < length; i++) {
      final int a = i < parts.length ? parts[i] : 0;
      final int b = i < other.parts.length ? other.parts[i] : 0;
      if (a != b) return a.compareTo(b);
    }
    return 0;
  }

  bool operator <(AppVersion other) => compareTo(other) < 0;

  @override
  List<Object?> get props => [parts];

  @override
  String toString() => parts.join('.');
}
