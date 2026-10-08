import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/core/theme/app_theme.dart';
import 'package:ssm/core/widgets/app_shimmer.dart';
import 'package:ssm/features/promotions/domain/entities/store_promotion.dart';
import 'package:ssm/features/promotions/domain/repos/promotions_repository.dart';
import 'package:ssm/features/promotions/presentation/cubit/promotions_cubit.dart';
import 'package:ssm/features/promotions/presentation/widgets/featured_slider_widget.dart';

import '../../helpers/fake_zone_repository.dart';
import '../../helpers/test_strings.dart';

class _FakePromotionsRepository implements PromotionsRepository {
  final Completer<Either<Failure, List<StorePromotion>>> answer = Completer();

  @override
  Future<Either<Failure, List<StorePromotion>>> getFeaturedPromotions({
    int page = 1,
    int limit = featuredPromotionsLimit,
  }) => answer.future;
}

const Size _designSize = Size(390, 844);

/// Banner-less promotions render the store-name fallback, so no test here
/// touches the network.
StorePromotion _promotion(int id, {String? videoUrl}) => StorePromotion(
  id: id,
  storeId: id * 10,
  storeName: 'Store $id',
  videoUrl: videoUrl,
);

void main() {
  setUpAll(installEnglishStrings);
  tearDownAll(removeTestStrings);

  late _FakePromotionsRepository repository;
  late List<String> visited;

  setUp(() => visited = <String>[]);

  Future<void> pumpSlider(
    WidgetTester tester, {
    Size screen = _designSize,
  }) async {
    tester.view.physicalSize = screen;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // A Completer resolves in the zone that created it, so the fake is made
    // here, inside the test's fake-async zone, for `pump` to deliver it.
    repository = _FakePromotionsRepository();
    final GoRouter router = GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (_, __) => Scaffold(
            // The provider closes the cubit when the tree is torn down.
            body: BlocProvider<PromotionsCubit>(
              create: (_) => PromotionsCubit(
                promotionsRepository: repository,
                zoneRepository: FakeZoneRepository(),
              )..load(),
              child: const Column(
                children: <Widget>[
                  FeaturedSliderWidget(bottomSpacing: 24),
                  Text('Below'),
                ],
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/store-details/:storeId',
          builder: (_, GoRouterState state) {
            visited.add(state.uri.path);
            return const SizedBox.shrink();
          },
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: _designSize,
        builder: (_, __) =>
            MaterialApp.router(theme: appTheme, routerConfig: router),
      ),
    );
  }

  Future<void> answer(
    WidgetTester tester,
    Either<Failure, List<StorePromotion>> result,
  ) async {
    repository.answer.complete(result);
    await tester.pump();
    await tester.pump();
  }

  double sliderHeight(WidgetTester tester) =>
      tester.getSize(find.byType(FeaturedSliderWidget)).height;

  testWidgets('shimmers while loading', (WidgetTester tester) async {
    await pumpSlider(tester);

    expect(find.byType(AppShimmer), findsOneWidget);
    expect(sliderHeight(tester), greaterThan(0));
  });

  testWidgets('keeps the shimmer height once the banners load', (
    WidgetTester tester,
  ) async {
    await pumpSlider(tester);
    final double loading = sliderHeight(tester);

    await answer(tester, Right(<StorePromotion>[_promotion(1), _promotion(2)]));

    expect(sliderHeight(tester), loading);
  });

  testWidgets('titles the card with the store name and a call to action', (
    WidgetTester tester,
  ) async {
    await pumpSlider(tester);
    await answer(tester, Right(<StorePromotion>[_promotion(1)]));

    expect(find.text('Store 1'), findsOneWidget);
    expect(find.text('Featured store'), findsOneWidget);
    expect(find.text('Shop now'), findsOneWidget);
  });

  testWidgets('without a store name, the title says featured store', (
    WidgetTester tester,
  ) async {
    await pumpSlider(tester);
    await answer(
      tester,
      const Right(<StorePromotion>[StorePromotion(id: 1, storeId: 10)]),
    );

    expect(find.text('Featured store'), findsOneWidget);
    expect(find.byIcon(Icons.storefront_outlined), findsOneWidget);
  });

  testWidgets('fits a small phone with large text and a long name', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpSlider(tester, screen: const Size(320, 640));
    await answer(
      tester,
      const Right(<StorePromotion>[
        StorePromotion(
          id: 1,
          storeId: 10,
          storeName: 'A store with a remarkably long name indeed',
        ),
      ]),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('fits a phone shorter than the design, with large text', (
    WidgetTester tester,
  ) async {
    // Text scales with the screen's width, so the strip under the banner
    // must too — not shrink with its height.
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpSlider(tester, screen: const Size(390, 600));
    await answer(tester, Right(<StorePromotion>[_promotion(1)]));

    expect(tester.takeException(), isNull);
  });

  testWidgets('disappears, gap included, when there are no promotions', (
    WidgetTester tester,
  ) async {
    await pumpSlider(tester);
    await answer(tester, const Right(<StorePromotion>[]));

    expect(sliderHeight(tester), 0);
    expect(find.text('Below'), findsOneWidget);
  });

  testWidgets('disappears when promotions fail to load', (
    WidgetTester tester,
  ) async {
    await pumpSlider(tester);
    await answer(tester, const Left(ServerFailure()));

    expect(sliderHeight(tester), 0);
  });

  testWidgets('shows a play badge only on a promotion with a video', (
    WidgetTester tester,
  ) async {
    await pumpSlider(tester);
    await answer(
      tester,
      Right(<StorePromotion>[
        _promotion(1, videoUrl: 'https://cdn.example.com/1.mp4'),
      ]),
    );

    expect(find.text('Store 1'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    expect(find.bySemanticsLabel('Store 1, Store video'), findsOneWidget);
  });

  testWidgets('shows no play badge without a video', (
    WidgetTester tester,
  ) async {
    await pumpSlider(tester);
    await answer(tester, Right(<StorePromotion>[_promotion(1)]));

    expect(find.text('Store 1'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
  });

  testWidgets('a tap opens the store in the app by its id', (
    WidgetTester tester,
  ) async {
    await pumpSlider(tester);
    await answer(tester, Right(<StorePromotion>[_promotion(2)]));

    await tester.tap(find.text('Store 2'));
    await tester.pumpAndSettle();

    expect(visited, <String>['/store-details/20']);
  });

  testWidgets('auto-plays to the next banner', (WidgetTester tester) async {
    await pumpSlider(tester);
    await answer(tester, Right(<StorePromotion>[_promotion(1), _promotion(2)]));
    final double startX = tester.getCenter(find.text('Store 1')).dx;

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(tester.getCenter(find.text('Store 2')).dx, closeTo(startX, 1));
  });

  testWidgets('does not auto-play when the OS reduces motion', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpSlider(tester);
    await answer(tester, Right(<StorePromotion>[_promotion(1), _promotion(2)]));
    final double startX = tester.getCenter(find.text('Store 1')).dx;

    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();

    expect(tester.getCenter(find.text('Store 1')).dx, startX);
  });
}
