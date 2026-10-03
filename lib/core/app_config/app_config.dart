import 'package:equatable/equatable.dart';

import 'app_version.dart';
import 'installed_app.dart';

/// `GET /config/customer` — app-wide settings an admin can change without a
/// release.
class AppConfig extends Equatable {
  final bool maintenanceMode;

  /// Null when the backend sets no minimum for that platform.
  final AppVersion? minimumAndroidVersion;
  final AppVersion? minimumIosVersion;

  /// Where the update button sends the customer; null when not configured.
  final String? androidStoreUrl;
  final String? iosStoreUrl;

  final String? supportPhone;
  final String? supportEmail;

  /// HTML documents, not links.
  final String? termsHtml;
  final String? privacyHtml;

  const AppConfig({
    required this.maintenanceMode,
    this.minimumAndroidVersion,
    this.minimumIosVersion,
    this.androidStoreUrl,
    this.iosStoreUrl,
    this.supportPhone,
    this.supportEmail,
    this.termsHtml,
    this.privacyHtml,
  });

  /// Whether [app] is older than the minimum for its platform. Unknown
  /// versions never block: a misreported version must not lock everyone out.
  bool requiresUpdate(InstalledApp app) {
    final AppVersion? installed = app.version;
    final AppVersion? minimum = switch (app.platform) {
      AppPlatform.android => minimumAndroidVersion,
      AppPlatform.ios => minimumIosVersion,
      AppPlatform.other => null,
    };
    if (installed == null || minimum == null) return false;
    return installed < minimum;
  }

  String? storeUrlFor(AppPlatform platform) => switch (platform) {
    AppPlatform.android => androidStoreUrl,
    AppPlatform.ios => iosStoreUrl,
    AppPlatform.other => null,
  };

  @override
  List<Object?> get props => [
    maintenanceMode,
    minimumAndroidVersion,
    minimumIosVersion,
    androidStoreUrl,
    iosStoreUrl,
    supportPhone,
    supportEmail,
    termsHtml,
    privacyHtml,
  ];
}
