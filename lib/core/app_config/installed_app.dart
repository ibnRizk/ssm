import 'package:equatable/equatable.dart';

import 'app_version.dart';

enum AppPlatform { android, ios, other }

/// This build of the app, as the device reports it.
class InstalledApp extends Equatable {
  /// Null when the platform reports a version that isn't dotted numbers.
  final AppVersion? version;
  final AppPlatform platform;

  const InstalledApp({required this.version, required this.platform});

  @override
  List<Object?> get props => [version, platform];
}
