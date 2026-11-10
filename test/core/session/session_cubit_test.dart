import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/session/session_cubit.dart';
import 'package:ssm/core/session/session_state.dart';

import '../../helpers/fake_session_repository.dart';

void main() {
  test('starts unknown', () {
    expect(
      SessionCubit(repository: FakeSessionRepository()).state,
      const SessionUnknown(),
    );
  });

  group('refresh', () {
    test('a stored token means signed in, even in guest mode', () async {
      final SessionCubit cubit = SessionCubit(
        repository: FakeSessionRepository(signedIn: true, guestChosen: true),
      );

      await cubit.refresh();

      expect(cubit.state, const SessionSignedIn());
    });

    test('no token but guest mode chosen means guest', () async {
      final SessionCubit cubit = SessionCubit(
        repository: FakeSessionRepository(guestChosen: true),
      );

      await cubit.refresh();

      expect(cubit.state, const SessionGuest());
    });

    test('neither means signed out', () async {
      final SessionCubit cubit = SessionCubit(
        repository: FakeSessionRepository(),
      );

      await cubit.refresh();

      expect(cubit.state, const SessionSignedOut());
    });
  });

  test('continueAsGuest remembers the choice and becomes guest', () async {
    final FakeSessionRepository repository = FakeSessionRepository();
    final SessionCubit cubit = SessionCubit(repository: repository);

    await cubit.continueAsGuest();

    expect(cubit.state, const SessionGuest());
    expect(repository.guestChosen, isTrue);
  });
}
