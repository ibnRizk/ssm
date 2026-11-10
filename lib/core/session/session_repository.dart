/// Who is using the app: a signed-in customer or a guest. There's no third
/// state — without a token the app is browsed as a guest (App Store
/// guideline 5.1.1(v)); only account-based features ask to sign in.
///
/// In `core/` because splash, onboarding, auth, home and the shell read it.
abstract class SessionRepository {
  /// True while an access token is stored.
  Future<bool> isSignedIn();

  /// The first-launch onboarding was completed or skipped. Never reset by
  /// signing in or out — it's about the device, not the account.
  bool get hasSeenOnboarding;

  Future<void> markOnboardingSeen();
}
