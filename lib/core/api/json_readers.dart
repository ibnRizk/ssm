/// Lenient readers for decoded JSON values. The backend (Laravel) may
/// serialise numbers as strings depending on the column type, so every
/// numeric read accepts both. Each returns null for anything unusable,
/// leaving the model to decide whether that's fatal.
library;

int? jsonInt(dynamic value) => switch (value) {
  final int v => v,
  final num v => v.toInt(),
  final String v => int.tryParse(v.trim()),
  _ => null,
};

double? jsonDouble(dynamic value) => switch (value) {
  final num v => v.toDouble(),
  final String v => double.tryParse(v.trim()),
  _ => null,
};

/// Trimmed, or null when missing, not a string, or blank.
String? jsonString(dynamic value) =>
    value is String && value.trim().isNotEmpty ? value.trim() : null;
