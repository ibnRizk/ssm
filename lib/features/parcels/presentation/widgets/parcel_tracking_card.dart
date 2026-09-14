import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/vertical_timeline.dart';

/// Placeholder shipment identity + freshness — swap for real tracking data
/// once the parcels API exists.
const String _placeholderShipmentId = 'شحنة #SSM-P2048';
const String _placeholderLastUpdated = 'آخر تحديث منذ 5 دقائق';

class ParcelTrackingCard extends StatelessWidget {
  const ParcelTrackingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      decoration: AppDecorations.card(),
      padding: EdgeInsets.all(AppSpacing.md.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                _placeholderShipmentId,
                style: AppTextStyles.titleSmall(color: c.textPrimary),
              ),
              const Spacer(),
              Text(
                _placeholderLastUpdated,
                style: AppTextStyles.caption(color: c.textSecondary),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg.h),
          VerticalTimeline(
            steps: <TimelineStep>[
              TimelineStep(
                title: Strings.parcelsStepArrivedTitle,
                subtitle: Strings.parcelsStepArrivedSubtitle,
                state: TimelineStepState.completed,
              ),
              TimelineStep(
                title: Strings.parcelsStepDeliveringTitle,
                subtitle: Strings.parcelsStepDeliveringSubtitle,
                state: TimelineStepState.active,
              ),
              TimelineStep(
                title: Strings.parcelsStepDeliveredTitle,
                subtitle: Strings.parcelsStepDeliveredSubtitle,
                state: TimelineStepState.pending,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
