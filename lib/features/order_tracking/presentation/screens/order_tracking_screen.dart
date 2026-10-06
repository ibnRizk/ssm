import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/values/launch_url_method.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/delivery_otp_card.dart';
import '../../../../core/widgets/error_text.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../../domain/entities/order_tracking.dart';
import '../cubit/order_tracking_cubit.dart';
import '../cubit/order_tracking_state.dart';
import '../utils/order_tracking_labels.dart';
import '../widgets/order_tracking_cancel_button.dart';
import '../widgets/order_tracking_contact_card.dart';
import '../widgets/order_tracking_items_card.dart';
import '../widgets/order_tracking_status_banner.dart';
import '../widgets/order_tracking_timeline_card.dart';

/// Order tracking — pushed as a top-level route outside [MainScaffold]'s
/// shell, so no bottom navigation bar. [OrderTrackingCubit] (provided by
/// the route, per order id) polls the status while this screen is open and
/// the app is visible — polling pauses while the app is in the background.
class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onHide: () => context.read<OrderTrackingCubit>().pausePolling(),
      onShow: () => context.read<OrderTrackingCubit>().resumePolling(),
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
        title: Strings.orderTrackingTitle,
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        child: BlocListener<OrderTrackingCubit, OrderTrackingState>(
          listenWhen: _cancellationChanged,
          listener: _announceCancellation,
          child: BlocBuilder<OrderTrackingCubit, OrderTrackingState>(
            builder: (BuildContext context, OrderTrackingState state) =>
                switch (state) {
                  OrderTrackingLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  OrderTrackingError(:final failure) => ErrorText(
                    message: failure.userMessage,
                    onRetry: () => context.read<OrderTrackingCubit>().load(),
                  ),
                  final OrderTrackingLoaded loaded => _TrackingContent(loaded),
                },
          ),
        ),
      ),
    );
  }

  static bool _cancellationChanged(
    OrderTrackingState previous,
    OrderTrackingState current,
  ) =>
      current is OrderTrackingLoaded &&
      previous is OrderTrackingLoaded &&
      previous.cancellation != current.cancellation;

  /// Here rather than on the cancel button: a successful cancel removes
  /// the button in the same state change.
  static void _announceCancellation(
    BuildContext context,
    OrderTrackingState state,
  ) {
    if (state is! OrderTrackingLoaded) return;
    switch (state.cancellation) {
      case CancellationDone():
        showAppSnackBar(
          context: context,
          message: Strings.orderCancelled,
          type: ToastType.success,
        );
      case CancellationFailed(:final Failure failure):
        showAppSnackBar(
          context: context,
          message: failure is ForbiddenFailure
              ? Strings.orderCancelNotAllowed
              : failure.userMessage,
          type: ToastType.error,
        );
      case CancellationIdle() || CancellationInProgress():
        break;
    }
  }
}

class _TrackingContent extends StatelessWidget {
  final OrderTrackingLoaded state;

  const _TrackingContent(this.state);

  @override
  Widget build(BuildContext context) {
    final OrderTrackingCubit cubit = context.read<OrderTrackingCubit>();
    final String storeName =
        state.summary.storeName ?? Strings.orderTrackingStoreLabel;
    return RefreshIndicator(
      onRefresh: cubit.refresh,
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
            OrderTrackingStatusBanner(
              headline: state.status.headline,
              description: state.status.description,
              orderId: state.summary.id,
              stale: state.stale,
            ),
            if (state.status.needsDeliveryOtp) ...<Widget>[
              SizedBox(height: AppSpacing.lg.h),
              DeliveryOtpCard(
                otp: state.otp,
                onRequest: cubit.requestDeliveryOtp,
              ),
            ],
            if (state.status.canBeCancelled) ...<Widget>[
              SizedBox(height: AppSpacing.md.h),
              const OrderTrackingCancelButton(),
            ],
            // Rejected or cancelled (by anyone): the order is over, so
            // offer the way back instead of a dead end.
            if (state.status.isFailed) ...<Widget>[
              SizedBox(height: AppSpacing.md.h),
              AppButton(
                btnText: Strings.orderTrackingBrowseStores,
                onPressed: () => context.go(AppRoutes.home),
              ),
            ],
            SizedBox(height: AppSpacing.lg.h),
            OrderTrackingTimelineCard(steps: state.status.timeline(storeName)),
            SizedBox(height: AppSpacing.lg.h),
            _Contact(state: state, storeName: storeName),
            if (state.lines.isNotEmpty) ...<Widget>[
              SizedBox(height: AppSpacing.lg.h),
              OrderTrackingItemsCard(
                lines: state.lines,
                deliveryCharge: state.summary.deliveryCharge,
                orderAmount: state.summary.orderAmount,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The courier while one is on the order (no phone is shared for them),
/// otherwise the store.
class _Contact extends StatelessWidget {
  final OrderTrackingLoaded state;
  final String storeName;

  const _Contact({required this.state, required this.storeName});

  @override
  Widget build(BuildContext context) {
    final OrderTracking? tracking = state.tracking;
    final String? driverName = tracking?.trackingAllowed ?? false
        ? tracking?.driverName
        : null;
    if (driverName != null) {
      final DriverLocation? location = tracking?.location;
      return OrderTrackingContactCard(
        name: driverName,
        subtitle:
            '${Strings.orderTrackingCourierLabel} · '
            '${location != null && location.isFresh ? Strings.orderTrackingLocationLive : Strings.orderTrackingLocationUnavailable}',
      );
    }
    final String? phone = state.summary.storePhone;
    return OrderTrackingContactCard(
      name: storeName,
      subtitle: state.status.headline,
      onCall: phone == null
          ? null
          : () => makePhoneCall(phoneNumber: phone, context: context),
    );
  }
}
