import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../../../../core/widgets/vertical_timeline.dart';
import '../widgets/order_tracking_contact_card.dart';
import '../widgets/order_tracking_status_banner.dart';
import '../widgets/order_tracking_timeline_card.dart';

/// Order-tracking screen — pushed as a top-level route outside
/// [MainScaffold]'s shell, same treatment as Cart and Order Confirmation, so
/// no bottom navigation bar here even though the design mock included one
/// (with a fake "tracking" tab).
///
/// Fully self-contained: unlike Cart/Order Confirmation, it doesn't read
/// [CartCubit] — once an order is placed there's nothing left to add or
/// remove, just a status to watch, so [storeName]/[orderNumber] are plain
/// constructor params instead.
class OrderTrackingScreen extends StatelessWidget {
  final String storeName;
  final String orderNumber;

  static const String defaultStoreName = 'مطاعم مذاق';
  static const String defaultOrderNumber = 'SSM-1048';

  const OrderTrackingScreen({
    super.key,
    this.storeName = defaultStoreName,
    this.orderNumber = defaultOrderNumber,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final List<TimelineStep> steps = <TimelineStep>[
      TimelineStep(
        title: Strings.orderTrackingStepSentTitle,
        subtitle: Strings.orderTrackingStepSentSubtitle,
        state: TimelineStepState.completed,
      ),
      TimelineStep(
        title: Strings.orderTrackingStepPreparingTitle,
        subtitle: Strings.orderTrackingStepPreparingSubtitle(storeName),
        state: TimelineStepState.active,
      ),
      TimelineStep(
        title: Strings.orderTrackingStepCourierToStoreTitle,
        subtitle: Strings.orderTrackingStepCourierToStoreSubtitle,
        state: TimelineStepState.pending,
      ),
      TimelineStep(
        title: Strings.orderTrackingStepCourierToYouTitle,
        subtitle: Strings.orderTrackingStepCourierToYouSubtitle,
        state: TimelineStepState.pending,
      ),
      TimelineStep(
        title: Strings.orderTrackingStepDeliveredTitle,
        subtitle: Strings.orderTrackingStepDeliveredSubtitle,
        state: TimelineStepState.pending,
      ),
    ];
    final TimelineStep currentStep = steps.firstWhere(
      (TimelineStep s) => s.state == TimelineStepState.active,
      orElse: () => steps.first,
    );

    return Scaffold(
      backgroundColor: c.background,
      appBar: SimpleAppBar(
        title: Strings.orderTrackingTitle,
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                currentStepTitle: currentStep.title,
                orderNumber: orderNumber,
              ),
              SizedBox(height: AppSpacing.lg.h),
              OrderTrackingTimelineCard(steps: steps),
              SizedBox(height: AppSpacing.lg.h),
              OrderTrackingContactCard(
                name: storeName,
                // TODO: swap for the real order status once the ordering
                // API exists — "قيد التجهيز" mirrors the current step.
                subtitle: 'قيد التجهيز · تحديث الآن',
                // TODO: launch an actual phone call once a real number
                // exists.
                onCall: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
