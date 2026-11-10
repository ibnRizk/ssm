import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ssm/config/routes/app_routes.dart';
import 'package:ssm/core/session/session_cubit.dart';
import 'package:ssm/core/session/session_state.dart';
import 'package:ssm/core/theme/app_theme.dart';
import 'package:ssm/core/utils/values/strings.dart';
import 'package:ssm/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:ssm/features/onboarding/presentation/widgets/onboarding_page.dart';

import '../../helpers/fake_session_repository.dart';
import '../../helpers/test_strings.dart';

/// No image URLs: the pages show their offline fallback, so nothing here
/// touches the network.
const List<OnboardingSlide> _slides = <OnboardingSlide>[
  OnboardingSlide(icon: Icons.storefront, title: 'Page one', body: 'One'),
  OnboardingSlide(icon: Icons.inventory_2, title: 'Page two', body: 'Two'),
  OnboardingSlide(icon: Icons.location_on, title: 'Page three', body: 'Three'),
];

void main() {
  late FakeSessionRepository repository;
  late SessionCubit session;

  setUpAll(installEnglishStrings);
  tearDownAll(removeTestStrings);

  setUp(() async {
    repository = FakeSessionRepository();
    session = SessionCubit(repository: repository);
    await session.refresh();
  });

  tearDown(() => session.close());

  Future<void> pumpOnboarding(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final GoRouter router = GoRouter(
      initialLocation: AppRoutes.onboarding,
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.onboarding,
          name: AppRoutes.onboardingName,
          builder: (_, __) => const OnboardingScreen(slides: _slides),
        ),
        GoRoute(
          path: AppRoutes.home,
          name: AppRoutes.homeName,
          builder: (_, __) => const Text('home screen'),
        ),
        GoRoute(
          path: AppRoutes.login,
          name: AppRoutes.loginName,
          builder: (_, __) => const Text('login screen'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) => BlocProvider<SessionCubit>.value(
          value: session,
          child: MaterialApp.router(theme: appTheme, routerConfig: router),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Next moves to the following page', (WidgetTester tester) async {
    await pumpOnboarding(tester);
    expect(find.text('Page one'), findsOneWidget);

    await tester.tap(find.text(Strings.onboardingNext));
    await tester.pumpAndSettle();

    expect(find.text('Page two'), findsOneWidget);
  });

  testWidgets('Skip enters Home as a guest and remembers onboarding', (
    WidgetTester tester,
  ) async {
    await pumpOnboarding(tester);

    await tester.tap(find.text(Strings.onboardingSkip));
    await tester.pumpAndSettle();

    expect(find.text('home screen'), findsOneWidget);
    expect(repository.onboardingSeen, isTrue);
    expect(session.state, const SessionGuest(hasSeenOnboarding: true));
  });

  testWidgets('the last page enters Home, never Login', (
    WidgetTester tester,
  ) async {
    await pumpOnboarding(tester);

    await tester.tap(find.text(Strings.onboardingNext));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Strings.onboardingNext));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Strings.onboardingGetStarted));
    await tester.pumpAndSettle();

    expect(find.text('home screen'), findsOneWidget);
    expect(find.text('login screen'), findsNothing);
  });
}
