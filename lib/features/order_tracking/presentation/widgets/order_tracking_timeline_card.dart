import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/vertical_timeline.dart';

/// The order-journey card. Unlike [ParcelTrackingCard], "completed" is
/// orange here and "active" (the current step) is navy — the reverse of
/// Parcels' palette — so the colour overrides are passed explicitly instead
/// of relying on [VerticalTimeline]'s Parcels-shaped defaults.
class OrderTrackingTimelineCard extends StatelessWidget {
  final List<TimelineStep> steps;

  const OrderTrackingTimelineCard({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      decoration: AppDecorations.card(c),
      padding: EdgeInsets.all(AppSpacing.md.r),
      child: VerticalTimeline(
        steps: steps,
        completedColor: c.secondary,
        activeColor: c.primary,
        pendingColor: c.border,
        activeTitleColor: c.textPrimary,
      ),
    );
  }
}
