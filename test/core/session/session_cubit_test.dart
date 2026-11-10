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
    test('a stored token means signed in', () async {
      final SessionCubit cubit = SessionCubit(
        repository: FakeSessionRepository(signedIn: true),
      );

      await cubit.refresh();

      expect(cubit.state, const SessionSignedIn());
    });

    test(
      'without a token, a first launch is a guest who needs onboarding',
      () async {
        final SessionCubit cubit = SessionCubit(
          repository: FakeSessionRepository(),
        );

        await cubit.refresh();

        expect(cubit.state, const SessionGuest(hasSeenOnboarding: false));
      },
    );

    test(
      'without a token, a returning device is a guest past onboarding',
      () async {
        final SessionCubit cubit = SessionCubit(
          repository: FakeSessionRepository(onboardingSeen: true),
        );

        await cubit.refresh();

        expect(cubit.state, const SessionGuest(hasSeenOnboarding: true));
      },
    );
  });

  test('completeOnboarding remembers it and enters as a guest', () async {
    final FakeSessionRepository repository = FakeSessionRepository();
    final SessionCubit cubit = SessionCubit(repository: repository);
    await cubit.refresh();

    await cubit.completeOnboarding();

    expect(cubit.state, const SessionGuest(hasSeenOnboarding: true));
    expect(repository.onboardingSeen, isTrue);
  });
}
