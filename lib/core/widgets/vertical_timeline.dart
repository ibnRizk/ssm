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
/// the exact same "completed / active / pending" visual language.
class VerticalTimeline extends StatelessWidget {
  final List<TimelineStep> steps;

  const VerticalTimeline({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (int i = 0; i < steps.length; i++)
          _TimelineRow(step: steps[i], isLast: i == steps.length - 1),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final TimelineStep step;
  final bool isLast;

  const _TimelineRow({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Color dotColor = switch (step.state) {
      TimelineStepState.completed => c.primary,
      TimelineStepState.active => c.secondary,
      TimelineStepState.pending => c.border,
    };
    final Color titleColor = switch (step.state) {
      TimelineStepState.completed => c.textPrimary,
      TimelineStepState.active => c.secondary,
      TimelineStepState.pending => c.textSecondary,
    };
    final Color lineColor = step.state == TimelineStepState.completed
        ? c.primary
        : c.border;

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
