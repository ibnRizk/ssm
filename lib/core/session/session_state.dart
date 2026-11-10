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

/// Browsing without an account. Account-based features ask to sign in.
final class SessionGuest extends SessionState {
  const SessionGuest();
}

/// Neither signed in nor chose guest mode — the app opens on Login.
final class SessionSignedOut extends SessionState {
  const SessionSignedOut();
}
