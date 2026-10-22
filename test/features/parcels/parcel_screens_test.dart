import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/delivery_otp/delivery_otp.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/core/location/geo_point.dart';
import 'package:ssm/core/location/location_repository.dart';
import 'package:ssm/core/theme/app_colors.dart';
import 'package:ssm/core/theme/app_theme.dart';
import 'package:ssm/core/utils/values/strings.dart';
import 'package:ssm/features/parcels/domain/entities/parcel.dart';
import 'package:ssm/features/parcels/domain/repos/parcels_repository.dart';
import 'package:ssm/features/parcels/presentation/cubit/parcels_cubit.dart';
import 'package:ssm/features/parcels/presentation/screens/parcel_detail_screen.dart';
import 'package:ssm/features/parcels/presentation/screens/parcels_screen.dart';
import 'package:ssm/features/parcels/presentation/widgets/parcels_feedback_listener.dart';
import 'package:ssm/features/parcels/presentation/widgets/parcels_polling_scope.dart';
import 'package:ssm/injection_container.dart';

import '../../helpers/test_strings.dart';

const Parcel _atWarehouse = Parcel(
  id: 2048,
  reference: 'SSM-P2048',
  status: ParcelStatus.atWarehouse,
  paymentType: ParcelPaymentType.prepaid,
  codAmount: 0,
  deliveryFee: 0,
  currency: 'SAR',
);

const Parcel _processing = Parcel(
  id: 7,
  reference: 'SSM-P7',
  status: ParcelStatus.processing,
  paymentType: ParcelPaymentType.prepaid,
  codAmount: 0,
  deliveryFee: 0,
  currency: 'SAR',
);

/// Answers at once with what each test sets.
class _FakeParcelsRepository implements ParcelsRepository {
  Either<Failure, List<Parcel>> list = const Right(<Parcel>[
    _atWarehouse,
  ]);
  Either<Failure, Parcel>? one;
  Either<Failure, Unit> send = const Right<Failure, Unit>(
    unit,
  );
  final List<int> detailRequests = <int>[];
  int listCalls = 0;

  @override
  Future<Either<Failure, List<Parcel>>> getParcels() async {
    listCalls++;
    return list;
  }

  @override
  Future<Either<Failure, Parcel>> getParcel(
    int parcelId,
  ) async {
    detailRequests.add(parcelId);
    return one ??
        list.fold(
          Left<Failure, Parcel>.new,
          (List<Parcel> l) => Right<Failure, Parcel>(
            l.firstWhere((Parcel p) => p.id == parcelId),
          ),
        );
  }

  @override
  Future<Either<Failure, Unit>> sendDropoff(
    int parcelId,
    ParcelDropoff dropoff,
  ) async => send;

  @override
  Future<Either<Failure, DeliveryOtp>> requestDeliveryOtp(
    int parcelId,
  ) async =>
      const Left<Failure, DeliveryOtp>(ConflictFailure());
}

class _FakeLocationRepository
    implements LocationRepository {
  @override
  Future<Either<Failure, GeoPoint>>
  getCurrentLocation() async =>
      const Right<Failure, GeoPoint>(
        GeoPoint(latitude: 24.705, longitude: 46.69),
      );
}

void main() {
  setUpAll(() {
    installEnglishStrings();
    // Some core widgets (buttons, snack bars) read the context-free colors.
    if (!ServiceLocator.instance
        .isRegistered<AppColors>()) {
      ServiceLocator.injectAppColors(AppColors.light);
    }
  });
  tearDownAll(() {
    removeTestStrings();
    ServiceLocator.instance.unregister<AppColors>();
  });

  late _FakeParcelsRepository parcels;

  setUp(() => parcels = _FakeParcelsRepository());

  /// Mounts [screen] the way the parcels route does: under one cubit and
  /// the snack-bar listener.
  Future<ParcelsCubit> pump(
    WidgetTester tester,
    Widget screen,
  ) async {
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final ParcelsCubit cubit = ParcelsCubit(
      parcelsRepository: parcels,
      locationRepository: _FakeLocationRepository(),
    );
    addTearDown(cubit.close);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) => MaterialApp(
          theme: appTheme,
          home: BlocProvider<ParcelsCubit>.value(
            value: cubit..fetchParcels(),
            child: ParcelsFeedbackListener(
              child: Scaffold(body: screen),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return cubit;
  }

  group('ParcelsScreen', () {
    // Regression: dispose() read the cubit through a deactivated context.
    testWidgets('leaves the tree without a lookup error', (
      WidgetTester tester,
    ) async {
      await pump(tester, const ParcelsScreen());

      await tester.pumpWidget(const SizedBox());

      expect(tester.takeException(), isNull);
    });
  });

  group('ParcelDetailScreen', () {
    testWidgets(
      'refetches the parcel and shows its timeline',
      (WidgetTester tester) async {
        await pump(
          tester,
          const ParcelDetailScreen(parcelId: 2048),
        );

        expect(parcels.detailRequests, <int>[2048]);
        expect(
          find.text(Strings.parcelsStepArrivedTitle),
          findsOneWidget,
        );
        expect(
          find.text(Strings.parcelsActionButton),
          findsOneWidget,
        );
      },
    );

    testWidgets('offers no drop-off before the warehouse', (
      WidgetTester tester,
    ) async {
      parcels.list = const Right(<Parcel>[_processing]);

      await pump(
        tester,
        const ParcelDetailScreen(parcelId: 7),
      );

      expect(
        find.text(Strings.parcelsStepArrivedTitle),
        findsOneWidget,
      );
      expect(
        find.text(Strings.parcelsActionButton),
        findsNothing,
      );
    });

    testWidgets('says so when the parcel is not found', (
      WidgetTester tester,
    ) async {
      parcels
        ..list = const Right(<Parcel>[])
        ..one = const Left<Failure, Parcel>(
          NotFoundFailure(),
        );

      await pump(
        tester,
        const ParcelDetailScreen(parcelId: 99),
      );

      expect(
        find.text(Strings.parcelsNotFound),
        findsOneWidget,
      );
    });

    testWidgets('shows a load failure with a retry', (
      WidgetTester tester,
    ) async {
      parcels.list = const Left(
        ServerFailure(message: 'Server is down'),
      );

      await pump(
        tester,
        const ParcelDetailScreen(parcelId: 2048),
      );

      expect(find.text('Server is down'), findsOneWidget);
    });

    // Regression: a drop-off sent from the details screen failed silently.
    testWidgets('announces a refused drop-off', (
      WidgetTester tester,
    ) async {
      parcels.send = const Left<Failure, Unit>(
        ServerFailure(
          message: 'The parcel has already been delivered.',
        ),
      );
      await pump(
        tester,
        const ParcelDetailScreen(parcelId: 2048),
      );

      await tester.tap(
        find.text(Strings.parcelsActionButton),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).first,
        'Gate 2',
      );
      await tester.tap(
        find.text(Strings.parcelsDropoffConfirm),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('The parcel has already been delivered.'),
        findsOneWidget,
      );
    });

    testWidgets('announces an accepted drop-off', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const ParcelDetailScreen(parcelId: 2048),
      );

      await tester.tap(
        find.text(Strings.parcelsActionButton),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).first,
        'Gate 2',
      );
      await tester.tap(
        find.text(Strings.parcelsDropoffConfirm),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(Strings.parcelsDropoffSent),
        findsOneWidget,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // ParcelsPollingScope widget tests
  //
  // Mount the scope with a controllable TickerMode wrapper to simulate tab
  // switches. Use tester.pump(Duration) instead of fakeAsync so the widget
  // tree participates (AppLifecycleListener registers via WidgetsBinding).
  // ---------------------------------------------------------------------------

  /// Mounts ParcelsPollingScope the same way the ShellRoute does:
  ///   TickerMode → BlocProvider<ParcelsCubit> → ParcelsPollingScope → child
  Future<
    ({ParcelsCubit cubit, _FakeParcelsRepository repo})
  >
  pumpScope(
    WidgetTester tester, {
    GlobalKey<_TickerToggleState>? tickerKey,
  }) async {
    final _FakeParcelsRepository repo =
        _FakeParcelsRepository();
    repo.list = const Right<Failure, List<Parcel>>(<Parcel>[
      _atWarehouse,
    ]);

    final ParcelsCubit cubit = ParcelsCubit(
      parcelsRepository: repo,
      locationRepository: _FakeLocationRepository(),
    );
    addTearDown(cubit.close);

    final GlobalKey<_TickerToggleState> key =
        tickerKey ?? GlobalKey<_TickerToggleState>();

    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) => MaterialApp(
          theme: appTheme,
          home: _TickerToggle(
            key: key,
            enabled: true,
            child: BlocProvider<ParcelsCubit>.value(
              value: cubit..fetchParcels(),
              child: ParcelsPollingScope(
                child: const SizedBox(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return (cubit: cubit, repo: repo);
  }

  group('ParcelsPollingScope', () {
    testWidgets(
      'starts polling on mount — timer fires after 30 s',
      (WidgetTester tester) async {
        final (:repo, cubit: _) = await pumpScope(tester);
        final int callsAfterMount = repo.listCalls;

        // Advance 30 s; the periodic timer fires one poll.
        await tester.pump(const Duration(seconds: 30));
        await tester.pump(); // flush the async fetch

        expect(repo.listCalls, callsAfterMount + 1);
      },
    );

    testWidgets(
      'stops polling when TickerMode is disabled (tab switch)',
      (WidgetTester tester) async {
        final GlobalKey<_TickerToggleState> key =
            GlobalKey();
        final (:repo, cubit: _) = await pumpScope(
          tester,
          tickerKey: key,
        );

        // Confirm polling is running.
        await tester.pump(const Duration(seconds: 30));
        await tester.pump();
        final int callsWhileVisible = repo.listCalls;

        // Simulate switching to another tab (indexedStack disables ticker).
        key.currentState!.setEnabled(enabled: false);
        await tester.pump();

        // Advance 30 s — timer should not fire.
        await tester.pump(const Duration(seconds: 30));
        await tester.pump();

        expect(repo.listCalls, callsWhileVisible);
      },
    );

    testWidgets(
      'resumes polling with an immediate fetch when ticker re-enables',
      (WidgetTester tester) async {
        final GlobalKey<_TickerToggleState> key =
            GlobalKey();
        final (:repo, cubit: _) = await pumpScope(
          tester,
          tickerKey: key,
        );

        // Simulate tab switch away.
        key.currentState!.setEnabled(enabled: false);
        await tester.pump();
        final int callsBeforeReturn = repo.listCalls;

        // Simulate returning to the parcels tab.
        repo.list = const Right<Failure, List<Parcel>>(
          <Parcel>[_atWarehouse],
        );
        key.currentState!.setEnabled(enabled: true);
        await tester
            .pump(); // didChangeDependencies fires → _resumePolling()
        await tester
            .pump(); // flush the immediate fetchParcels(silent: true)

        // One immediate refresh was issued on resume.
        expect(repo.listCalls, callsBeforeReturn + 1);

        // The new timer also fires after 30 s.
        await tester.pump(const Duration(seconds: 30));
        await tester.pump();
        expect(repo.listCalls, callsBeforeReturn + 2);
      },
    );

    testWidgets('stops polling when the app is hidden', (
      WidgetTester tester,
    ) async {
      // AppLifecycleListener fires onHide only on the inactive→hidden transition.
      // Reset the binding to a known state (resumed) before mounting, then use
      // the proper two-step hide sequence in the test body.
      // The reset calls happen before pumpScope (no listener mounted yet).
      tester.binding
          .handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding
          .handleAppLifecycleStateChanged(AppLifecycleState.resumed);

      final (:repo, cubit: _) = await pumpScope(tester);

      await tester.pump(const Duration(seconds: 30));
      await tester.pump();
      final int callsBeforeHide = repo.listCalls;

      // Proper hide sequence: resumed → inactive → hidden (onHide fires on hidden).
      tester.binding
          .handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      tester.binding
          .handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await tester.pump();

      await tester.pump(const Duration(seconds: 30));
      await tester.pump();

      expect(repo.listCalls, callsBeforeHide);
    });

    testWidgets(
      'resumes polling with an immediate fetch on app show',
      (WidgetTester tester) async {
        // Reset binding to a known state before mounting.
        tester.binding
            .handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        tester.binding
            .handleAppLifecycleStateChanged(AppLifecycleState.resumed);

        final (:repo, cubit: _) = await pumpScope(tester);

        // Hide: inactive → hidden (onHide fires on hidden, stopPolling).
        tester.binding
            .handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        await tester.pump();
        tester.binding
            .handleAppLifecycleStateChanged(AppLifecycleState.hidden);
        await tester.pump();
        final int callsBeforeShow = repo.listCalls;

        // Show: hidden → inactive (onShow fires on inactive, _resumePolling).
        repo.list = const Right<Failure, List<Parcel>>(<Parcel>[_atWarehouse]);
        tester.binding
            .handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        await tester.pump();
        await tester.pump(); // flush the immediate fetchParcels(silent: true)

        expect(repo.listCalls, callsBeforeShow + 1);
      },
    );

    testWidgets(
      'disposing the scope cancels polling without exceptions',
      (WidgetTester tester) async {
        await pumpScope(tester);

        // Unmount everything.
        await tester.pumpWidget(const SizedBox());

        expect(tester.takeException(), isNull);
      },
    );
  });
}

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

/// A StatefulWidget that lets tests toggle [TickerMode] dynamically, to
/// simulate the `StatefulShellRoute.indexedStack` hiding and showing branches.
class _TickerToggle extends StatefulWidget {
  const _TickerToggle({
    super.key,
    required this.enabled,
    required this.child,
  });

  final bool enabled;
  final Widget child;

  @override
  State<_TickerToggle> createState() =>
      _TickerToggleState();
}

class _TickerToggleState extends State<_TickerToggle> {
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _enabled = widget.enabled;
  }

  void setEnabled({required bool enabled}) {
    setState(() => _enabled = enabled);
  }

  @override
  Widget build(BuildContext context) =>
      TickerMode(enabled: _enabled, child: widget.child);
}
