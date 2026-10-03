import '../api/json_readers.dart';
import '../error/exceptions.dart';
import 'app_config.dart';
import 'app_version.dart';

/// `{ support { phone, email }, legal { terms, privacy }, application { name,
/// currency, timezone, maintenance_mode, minimum_versions { android, ios },
/// store_urls { android, ios } } }`.
class AppConfigModel extends AppConfig {
  const AppConfigModel({
    required super.maintenanceMode,
    super.minimumAndroidVersion,
    super.minimumIosVersion,
    super.androidStoreUrl,
    super.iosStoreUrl,
    super.supportPhone,
    super.supportEmail,
    super.termsHtml,
    super.privacyHtml,
  });

  /// Throws [ServerException] when the body has no `application` object.
  /// Everything inside it is optional.
  factory AppConfigModel.fromJson(dynamic json) {
    final dynamic application = json is Map ? json['application'] : null;
    if (application is! Map) throw const ServerException();
    final Map<dynamic, dynamic> minimum = _map(application['minimum_versions']);
    final Map<dynamic, dynamic> stores = _map(application['store_urls']);
    final Map<dynamic, dynamic> support = _map(json['support']);
    final Map<dynamic, dynamic> legal = _map(json['legal']);
    return AppConfigModel(
      maintenanceMode: jsonBool(application['maintenance_mode']) ?? false,
      minimumAndroidVersion: _version(minimum['android']),
      minimumIosVersion: _version(minimum['ios']),
      androidStoreUrl: jsonHttpUrl(stores['android']),
      iosStoreUrl: jsonHttpUrl(stores['ios']),
      supportPhone: jsonString(support['phone']),
      supportEmail: jsonString(support['email']),
      termsHtml: jsonString(legal['terms']),
      privacyHtml: jsonString(legal['privacy']),
    );
  }

  static Map<dynamic, dynamic> _map(dynamic value) =>
      value is Map ? value : const <dynamic, dynamic>{};

  /// The backend sends a number today (`0` = no minimum, like `1.2`) but a
  /// `"1.2.0"` string reads the same way.
  static AppVersion? _version(dynamic value) => switch (value) {
    final num v => AppVersion.tryParse('$v'),
    final String v => AppVersion.tryParse(v),
    _ => null,
  };
}
