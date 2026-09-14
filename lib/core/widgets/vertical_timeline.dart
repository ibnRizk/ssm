import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// Where a [TimelineStep] stands relative to "now" — drives its dot, line and
/// title colour in [VerticalTimeline].
enum TimelineStepState { completed, active, pending }

class TimelineStep {
  final String title;
  final String subtitle;
  final TimelineStepState state;

  const TimelineStep({
    required this.title,
    required this.subtitle,
    required this.state,
  });
}

/// A vertical status stepper — dot-and-line on the start side, title and
/// subtitle on the end side. Used by parcel and order tracking, which share
/// the exact same layout but not the exact same palette: Parcels marks
/// "completed" navy and "active" orange, while Order Tracking does the
/// reverse (orange for what already happened, navy for "you are here").
/// The three colour overrides default to Parcels' original look, so its
/// call site (no overrides passed) renders exactly as before.
class VerticalTimeline extends StatelessWidget {
  final List<TimelineStep> steps;
  final Color? completedColor;
  final Color? activeColor;
  final Color? pendingColor;

  /// The *active* step's title colour only — completed/pending titles are
  /// always [AppColors.textPrimary]/[AppColors.textSecondary], since both
  /// screens agree on those.
  final Color? activeTitleColor;

  const VerticalTimeline({
    super.key,
    required this.steps,
    this.completedColor,
    this.activeColor,
    this.pendingColor,
    this.activeTitleColor,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Color resolvedCompleted = completedColor ?? c.primary;
    final Color resolvedActive = activeColor ?? c.secondary;
    final Color resolvedPending = pendingColor ?? c.border;
    final Color resolvedActiveTitle = activeTitleColor ?? c.secondary;
    return Column(
      children: <Widget>[
        for (int i = 0; i < steps.length; i++)
          _TimelineRow(
            step: steps[i],
            isLast: i == steps.length - 1,
            completedColor: resolvedCompleted,
            activeColor: resolvedActive,
            pendingColor: resolvedPending,
            activeTitleColor: resolvedActiveTitle,
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final TimelineStep step;
  final bool isLast;
  final Color completedColor;
  final Color activeColor;
  final Color pendingColor;
  final Color activeTitleColor;

  const _TimelineRow({
    required this.step,
    required this.isLast,
    required this.completedColor,
    required this.activeColor,
    required this.pendingColor,
    required this.activeTitleColor,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Color dotColor = switch (step.state) {
      TimelineStepState.completed => completedColor,
      TimelineStepState.active => activeColor,
      TimelineStepState.pending => pendingColor,
    };
    final Color titleColor = switch (step.state) {
      TimelineStepState.completed => c.textPrimary,
      TimelineStepState.active => activeTitleColor,
      TimelineStepState.pending => c.textSecondary,
    };
    final Color lineColor = step.state == TimelineStepState.completed
        ? completedColor
        : pendingColor;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: 12.r,
                height: 12.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: EdgeInsets.symmetric(vertical: 2.h),
                    color: lineColor,
                  ),
                ),
            ],
          ),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    step.title,
                    style: AppTextStyles.titleSmall(color: titleColor),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    step.subtitle,
                    style: AppTextStyles.caption(color: c.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
