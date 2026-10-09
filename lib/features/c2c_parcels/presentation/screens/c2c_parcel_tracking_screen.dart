import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/location/geo_point.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/error_text.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../../../../core/widgets/vertical_timeline.dart';
import '../../domain/entities/c2c_parcel.dart';
import '../cubit/c2c_parcel_tracking_cubit.dart';
import '../cubit/c2c_parcel_tracking_state.dart';
import '../utils/c2c_parcel_labels.dart';
import '../utils/c2c_parcel_timeline.dart';
import '../widgets/c2c_driver_card.dart';
import '../widgets/c2c_parcel_action_buttons.dart';
import '../widgets/c2c_parcel_info_card.dart';
import '../widgets/c2c_parcel_map.dart';
import '../widgets/c2c_status_banner.dart';

/// One door-to-door parcel, live — for its sender or its recipient.
/// Pushed outside the shell, so no bottom navigation bar. The
/// [C2cParcelTrackingCubit] (provided by the route, per parcel id) follows
/// realtime events and polls while the socket is down; polling pauses
/// while the app is in the background.
class C2cParcelTrackingScreen extends StatefulWidget {
  const C2cParcelTrackingScreen({super.key});

  @override
  State<C2cParcelTrackingScreen> createState() =>
      _C2cParcelTrackingScreenState();
}

class _C2cParcelTrackingScreenState extends State<C2cParcelTrackingScreen> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onHide: () => context.read<C2cParcelTrackingCubit>().pausePolling(),
      onShow: () => context.read<C2cParcelTrackingCubit>().resumePolling(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: SimpleAppBar(
        title: Strings.c2cTrackingTitle,
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        child: _CommandResultListener(
          child: BlocBuilder<C2cParcelTrackingCubit, C2cParcelTrackingState>(
            // Commands and codes rebuild only their own widgets, and so does
            // a moving driver: only the map follows it (see [_LiveMap]).
            buildWhen:
                (
                  C2cParcelTrackingState previous,
                  C2cParcelTrackingState current,
                ) =>
                    previous.runtimeType != current.runtimeType ||
                    (previous is C2cTrackingLoaded &&
                        current is C2cTrackingLoaded &&
                        (previous.details != current.details ||
                            (previous.tracking != current.tracking &&
                                !_onlyDriverMoved(
                                  previous.tracking,
                                  current.tracking,
                                )))),
            builder: (BuildContext context, C2cParcelTrackingState state) =>
                switch (state) {
                  C2cTrackingLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  C2cTrackingError(:final failure) => ErrorText(
                    message: failure.c2cMessage,
                    onRetry: () =>
                        context.read<C2cParcelTrackingCubit>().load(),
                  ),
                  final C2cTrackingLoaded loaded => _TrackingContent(loaded),
                },
          ),
        ),
      ),
    );
  }

  /// Equal except for a driver who moved and is still on the map. Their
  /// appearing or vanishing does rebuild — the driver card shows it.
  static bool _onlyDriverMoved(
    C2cParcelTracking? previous,
    C2cParcelTracking? current,
  ) {
    final C2cDriverLocation? moved = current?.driverLocation;
    return previous != null &&
        current != null &&
        previous.driverLocation != null &&
        moved != null &&
        previous.withDriverLocation(moved) == current;
  }
}

class _TrackingContent extends StatelessWidget {
  final C2cTrackingLoaded state;

  const _TrackingContent(this.state);

  @override
  Widget build(BuildContext context) {
    final C2cParcelDetails parcel = state.details;
    final C2cParcelTracking? tracking = state.tracking;
    final C2cDriver? driver = tracking?.driver ?? parcel.driver;
    final GeoPoint? driverPoint = tracking?.driverLocation?.point;
    // The live view's points first; the details' as a fallback. The
    // recipient never gets the pickup point (`tracking.pickup` is null).
    final GeoPoint? pickup = tracking != null
        ? tracking.pickup
        : (parcel.isSender ? parcel.sender.location : null);
    final GeoPoint? dropoff =
        tracking?.destination ?? parcel.recipient.location;

    return RefreshIndicator(
      onRefresh: context.read<C2cParcelTrackingCubit>().refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screen.w,
          AppSpacing.md.h,
          AppSpacing.screen.w,
          AppSpacing.xxl.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            C2cStatusBanner(
              status: parcel.status,
              reference: parcel.reference,
              role: parcel.viewerRole,
              etaMinutes: tracking?.etaMinutes,
            ),
            if (pickup != null || dropoff != null) ...<Widget>[
              SizedBox(height: AppSpacing.md.h),
              _LiveMap(pickup: pickup, dropoff: dropoff),
            ],
            if (driver != null) ...<Widget>[
              SizedBox(height: AppSpacing.md.h),
              C2cDriverCard(driver: driver, isLive: driverPoint != null),
            ],
            SizedBox(height: AppSpacing.md.h),
            C2cParcelActionButtons(parcel: parcel),
            SizedBox(height: AppSpacing.md.h),
            _TimelineCard(parcel: parcel),
            SizedBox(height: AppSpacing.md.h),
            C2cParcelInfoCard(parcel: parcel),
          ],
        ),
      ),
    );
  }
}

/// The map, rebuilt on its own as the driver moves — the rest of the
/// screen stays as it is.
class _LiveMap extends StatelessWidget {
  final GeoPoint? pickup;
  final GeoPoint? dropoff;

  const _LiveMap({required this.pickup, required this.dropoff});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      C2cParcelTrackingCubit,
      C2cParcelTrackingState,
      GeoPoint?
    >(
      selector: (C2cParcelTrackingState state) => state is C2cTrackingLoaded
          ? state.tracking?.driverLocation?.point
          : null,
      builder: (BuildContext context, GeoPoint? driver) =>
          C2cParcelMap(pickup: pickup, dropoff: dropoff, driver: driver),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final C2cParcelDetails parcel;

  const _TimelineCard({required this.parcel});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      decoration: AppDecorations.card(c),
      padding: EdgeInsets.all(AppSpacing.md.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            Strings.c2cTrackingTimelineTitle,
            style: AppTextStyles.title(color: c.textPrimary),
          ),
          SizedBox(height: AppSpacing.md.h),
          VerticalTimeline(
            steps: c2cTimelineSteps(
              parcel,
              languageCode: Localizations.localeOf(context).languageCode,
            ),
          ),
        ],
      ),
    );
  }
}

/// One snack bar per finished command, then acknowledges it so it isn't
/// shown again. Never rebuilds [child].
class _CommandResultListener extends StatelessWidget {
  final Widget child;

  const _CommandResultListener({required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<C2cParcelTrackingCubit, C2cParcelTrackingState>(
      // Only when the command status itself changes: an unrelated emit
      // before [clearCommand] must not announce the same result twice.
      listenWhen:
          (C2cParcelTrackingState previous, C2cParcelTrackingState current) =>
              current is C2cTrackingLoaded &&
              (current.command is C2cCommandDone ||
                  current.command is C2cCommandFailed) &&
              (previous is! C2cTrackingLoaded ||
                  previous.command != current.command),
      listener: (BuildContext context, C2cParcelTrackingState state) {
        final C2cParcelTrackingCubit cubit = context
            .read<C2cParcelTrackingCubit>();
        switch ((state as C2cTrackingLoaded).command) {
          case C2cCommandDone(:final command):
            showAppSnackBar(
              context: context,
              message: switch (command) {
                C2cCommand.cancel => Strings.c2cTrackingCancelled,
                C2cCommand.retryDispatch => Strings.c2cTrackingRetried,
                C2cCommand.support => Strings.c2cTrackingSupportSent,
              },
              type: ToastType.success,
            );
          case C2cCommandFailed(:final failure):
            showAppSnackBar(
              context: context,
              message: failure.c2cMessage,
              type: ToastType.error,
            );
          case C2cCommandIdle() || C2cCommandInProgress():
            break;
        }
        cubit.clearCommand();
      },
      child: child,
    );
  }
}
