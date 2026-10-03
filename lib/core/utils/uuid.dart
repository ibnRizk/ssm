import 'dart:math';

final Random _random = Random.secure();

/// A random (version 4) UUID, e.g. `3b241101-e2bb-4255-8caf-4136c566a962`,
/// from a cryptographically secure source.
String uuidV4() {
  final List<int> bytes = List<int>.generate(16, (_) => _random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
  bytes[8] = (bytes[8] & 0x3f) | 0x80; // RFC 4122 variant
  final String hex = bytes
      .map((int b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
