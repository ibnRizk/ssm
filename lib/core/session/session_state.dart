import 'package:equatable/equatable.dart';

sealed class SessionState extends Equatable {
  const SessionState();

  bool get isSignedIn => this is SessionSignedIn;

  @override
  List<Object?> get props => [];
}

/// Not read yet — the splash screen resolves it.
final class SessionUnknown extends SessionState {
  const SessionUnknown();
}

final class SessionSignedIn extends SessionState {
  const SessionSignedIn();
}

/// Browsing without an account — the default. Account-based features ask
/// to sign in (see `ensureSignedIn`).
final class SessionGuest extends SessionState {
  /// False on a first launch: the splash routes to onboarding.
  final bool hasSeenOnboarding;

  const SessionGuest({required this.hasSeenOnboarding});

  @override
  List<Object?> get props => [hasSeenOnboarding];
}
