import 'package:ssm/core/session/session_repository.dart';

class FakeSessionRepository implements SessionRepository {
  bool signedIn;
  bool onboardingSeen;

  FakeSessionRepository({this.signedIn = false, this.onboardingSeen = false});

  @override
  Future<bool> isSignedIn() async => signedIn;

  @override
  bool get hasSeenOnboarding => onboardingSeen;

  @override
  Future<void> markOnboardingSeen() async => onboardingSeen = true;
}
