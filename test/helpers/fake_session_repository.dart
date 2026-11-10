import 'package:ssm/core/session/session_repository.dart';

class FakeSessionRepository implements SessionRepository {
  bool signedIn;
  bool guestChosen;

  FakeSessionRepository({this.signedIn = false, this.guestChosen = false});

  @override
  Future<bool> isSignedIn() async => signedIn;

  @override
  bool get isGuestModeChosen => guestChosen;

  @override
  Future<void> chooseGuestMode() async => guestChosen = true;
}
