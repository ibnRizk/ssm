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
          : repository.isGuestModeChosen
          ? const SessionGuest()
          : const SessionSignedOut(),
    );
  }

  Future<void> continueAsGuest() async {
    await repository.chooseGuestMode();
    if (!isClosed) emit(const SessionGuest());
  }
}
