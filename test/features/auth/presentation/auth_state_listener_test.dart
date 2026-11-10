import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:ssm/config/routes/app_routes.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/features/auth/domain/entities/login_credentials.dart';
import 'package:ssm/features/auth/domain/entities/registration_details.dart';
import 'package:ssm/features/auth/domain/repos/auth_repository.dart';
import 'package:ssm/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ssm/features/auth/presentation/widgets/auth_state_listener.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ssm/core/session/session_cubit.dart';
import 'package:ssm/core/session/session_state.dart';

import '../../../helpers/fake_session_repository.dart';

class _SucceedingRepository implements AuthRepository {
  @override
  Future<Either<Failure, Unit>> login(LoginCredentials credentials) async =>
      const Right<Failure, Unit>(unit);

  @override
  Future<Either<Failure, Unit>> register(RegistrationDetails details) async =>
      const Right<Failure, Unit>(unit);

  @override
  Future<Either<Failure, Unit>> logout() async =>
      const Right<Failure, Unit>(unit);

  @override
  Future<Either<Failure, Unit>> requestPasswordReset(String phone) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> verifyPasswordResetCode({
    required String phone,
    required String code,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String phone,
    required String code,
    required String password,
  }) => throw UnimplementedError();
}

/// A screen that triggers [action] on the route-scoped [AuthCubit].
Widget _authScreen(String label, Future<void> Function(AuthCubit) action) {
  return BlocProvider<AuthCubit>(
    create: (_) => AuthCubit(repository: _SucceedingRepository()),
    child: AuthStateListener(
      child: Builder(
        builder: (BuildContext context) => Scaffold(
          body: TextButton(
            onPressed: () => action(context.read<AuthCubit>()),
            child: Text(label),
          ),
        ),
      ),
    ),
  );
}

/// Same shape as the app: auth routes and the signed-in area are siblings,
/// with a detail page pushed on top of home to prove the stack is dropped.
GoRouter _router(String initialLocation) => GoRouter(
  initialLocation: initialLocation,
  routes: <RouteBase>[
    // Re-entry after sign-out: the real splash then opens Home as a guest.
    GoRoute(
      path: AppRoutes.splash,
      name: AppRoutes.splashName,
      builder: (_, __) => const Scaffold(body: Text('splash screen')),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: AppRoutes.loginName,
      builder: (_, __) => _authScreen(
        'login screen',
        (AuthCubit cubit) =>
            cubit.login(phone: '0512345678', password: 'secret123'),
      ),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: AppRoutes.registerName,
      builder: (_, __) => _authScreen(
        'sign up',
        (AuthCubit cubit) => cubit.register(
          name: 'Sara Customer',
          phone: '0512345678',
          email: 'sara@ssm.test',
          password: 'secret123',
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: AppRoutes.homeName,
      builder: (_, __) => const Scaffold(body: Text('home screen')),
      routes: <RouteBase>[
        GoRoute(
          path: 'profile',
          builder: (_, __) =>
              _authScreen('log out', (AuthCubit cubit) => cubit.logout()),
        ),
      ],
    ),
  ],
);

/// The app provides the [SessionCubit] above the router.
Widget _app(GoRouter router, SessionCubit session) =>
    BlocProvider<SessionCubit>.value(
      value: session,
      child: MaterialApp.router(routerConfig: router),
    );

void main() {
  late FakeSessionRepository sessionRepository;
  late SessionCubit session;

  setUp(() {
    sessionRepository = FakeSessionRepository();
    session = SessionCubit(repository: sessionRepository);
  });

  tearDown(() => session.close());

  testWidgets(
    'logout re-enters as a guest (via the splash), not Login, with nothing '
    'to go back to',
    (WidgetTester tester) async {
      sessionRepository.onboardingSeen = true;
      final GoRouter router = _router('${AppRoutes.home}/profile');
      addTearDown(router.dispose);
      await tester.pumpWidget(_app(router, session));
      expect(router.canPop(), isTrue); // profile sits on top of home

      await tester.tap(find.text('log out'));
      await tester.pumpAndSettle();

      expect(find.text('splash screen'), findsOneWidget);
      expect(find.text('login screen'), findsNothing);
      expect(router.canPop(), isFalse);
      expect(session.state, const SessionGuest(hasSeenOnboarding: true));
    },
  );

  testWidgets('sign-up lands on Home, not Login, with nothing to go back to', (
    WidgetTester tester,
  ) async {
    final GoRouter router = _router(AppRoutes.register);
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(router, session));

    await tester.tap(find.text('sign up'));
    await tester.pumpAndSettle();

    expect(find.text('home screen'), findsOneWidget);
    expect(find.text('login screen'), findsNothing);
    expect(router.canPop(), isFalse);
  });

  testWidgets(
    'Login pushed by a guest sign-in gate pops back with true once signed in',
    (WidgetTester tester) async {
      final GoRouter router = _router(AppRoutes.home);
      addTearDown(router.dispose);
      await tester.pumpWidget(_app(router, session));

      final Future<bool?> result = router.pushNamed<bool>(AppRoutes.loginName);
      await tester.pumpAndSettle();
      sessionRepository.signedIn = true; // the repository stored the token
      await tester.tap(find.text('login screen'));
      await tester.pumpAndSettle();

      expect(await result, isTrue);
      expect(find.text('home screen'), findsOneWidget);
      expect(session.state, const SessionSignedIn());
    },
  );

  testWidgets('sign-in refreshes the session before entering the app', (
    WidgetTester tester,
  ) async {
    final GoRouter router = _router(AppRoutes.login);
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(router, session));
    sessionRepository.signedIn = true;

    await tester.tap(find.text('login screen'));
    await tester.pumpAndSettle();

    expect(find.text('home screen'), findsOneWidget);
    expect(session.state, const SessionSignedIn());
  });
}
