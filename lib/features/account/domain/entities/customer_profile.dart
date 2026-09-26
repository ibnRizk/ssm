import 'package:equatable/equatable.dart';

class CustomerProfile extends Equatable {
  final String name;

  /// As stored server-side (E.164, e.g. `+966512345678`).
  final String phone;

  /// Null when the backend omits or garbles `created_at`.
  final DateTime? createdAt;

  const CustomerProfile({
    required this.name,
    required this.phone,
    this.createdAt,
  });

  /// First character of the name for the avatar, or `?` when there's none.
  /// Uses runes, not code units, so a leading emoji or supplementary-plane
  /// letter isn't cut in half.
  String get initial {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return String.fromCharCode(trimmed.runes.first).toUpperCase();
  }

  int? get memberSinceYear => createdAt?.year;

  @override
  List<Object?> get props => [name, phone, createdAt];
}
