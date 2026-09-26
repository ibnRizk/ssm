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

/// An absolute http(s) URL, or null. Image fields may hold a bare file name
/// that only resolves against a server-side base path — useless to the app.
String? jsonHttpUrl(dynamic value) {
  final String? url = jsonString(value);
  final Uri? uri = url == null ? null : Uri.tryParse(url);
  if (uri == null || !uri.hasAuthority) return null;
  return uri.isScheme('http') || uri.isScheme('https') ? url : null;
}

/// `1`, `"1"`, `true` → true; `0`, `"0"`, `false` → false; else null.
bool? jsonBool(dynamic value) => switch (value) {
  final bool v => v,
  final num v => v != 0,
  final String v => switch (v.trim().toLowerCase()) {
    '1' || 'true' => true,
    '0' || 'false' => false,
    _ => null,
  },
  _ => null,
};
