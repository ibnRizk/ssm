import 'package:flutter_bloc/flutter_bloc.dart';

import 'session_repository.dart';
import 'session_state.dart';

/// App-wide (a lazy singleton provided above the router). Re-read with
/// [refresh] after anything that changes the stored token: splash, sign-in,
/// sign-out, a 401.
class SessionCubit extends Cubit<SessionState> {
  final SessionRepository repository;

  SessionCubit({required this.repository}) : super(const SessionUnknown());

  Future<void> refresh() async {
    final bool signedIn = await repository.isSignedIn();
    if (isClosed) return;
    emit(
      signedIn
          ? const SessionSignedIn()
          : SessionGuest(hasSeenOnboarding: repository.hasSeenOnboarding),
    );
  }

  /// Onboarding finished or skipped — straight into the app as a guest.
  Future<void> completeOnboarding() async {
    await repository.markOnboardingSeen();
    if (isClosed || state.isSignedIn) return;
    emit(const SessionGuest(hasSeenOnboarding: true));
  }
}
