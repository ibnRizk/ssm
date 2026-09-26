import '../../../../core/error/exceptions.dart';
import '../../domain/entities/customer_profile.dart';

/// `GET /customer/info` — the profile object at the top level.
class CustomerProfileModel extends CustomerProfile {
  const CustomerProfileModel({
    required super.name,
    required super.phone,
    super.createdAt,
  });

  /// Throws [ServerException] when the body isn't a profile at all.
  factory CustomerProfileModel.fromJson(dynamic json) {
    if (json is! Map) throw const ServerException();
    final String? phone = _string(json['phone']);
    if (phone == null) throw const ServerException();
    return CustomerProfileModel(
      name: _nameOf(json),
      phone: phone,
      createdAt: DateTime.tryParse(_string(json['created_at']) ?? ''),
    );
  }

  /// Sign-up takes a single `name`, but legacy customer controllers answer
  /// with `f_name`/`l_name` — accept either.
  static String _nameOf(Map<dynamic, dynamic> json) {
    final String? name = _string(json['name']);
    if (name != null) return name;
    return <String?>[
      _string(json['f_name']),
      _string(json['l_name']),
    ].whereType<String>().join(' ');
  }

  static String? _string(dynamic value) =>
      value is String && value.trim().isNotEmpty ? value.trim() : null;
}
