import 'package:equatable/equatable.dart';

sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

final class SplashLoading extends SplashState {
  const SplashLoading();
}

/// Continue into the app.
final class SplashReady extends SplashState {
  const SplashReady();
}

/// This build is below the backend's minimum. Blocks the app.
final class SplashUpdateRequired extends SplashState {
  /// Null when the backend has no store link for this platform.
  final String? storeUrl;

  const SplashUpdateRequired({this.storeUrl});

  @override
  List<Object?> get props => [storeUrl];
}

/// The backend is in maintenance mode. Blocks the app until a retry finds it
/// back up.
final class SplashMaintenance extends SplashState {
  const SplashMaintenance();
}
