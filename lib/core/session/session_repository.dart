/// Who is using the app: a signed-in customer, a guest, or nobody yet.
///
/// In `core/` because splash, auth, home and the shell all read it.
abstract class SessionRepository {
  /// True while an access token is stored.
  Future<bool> isSignedIn();

  /// The customer chose "Continue as guest" and hasn't signed in since.
  bool get isGuestModeChosen;

  /// Remembers the choice, so the next launch opens on Home, not Login.
  Future<void> chooseGuestMode();
}
