import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/vertical_timeline.dart';
import '../../domain/entities/parcel.dart';
import '../utils/parcel_labels.dart';
import 'parcel_summary.dart';

/// A parcel that reached the warehouse: reference, freshness, payment, and
/// the warehouse → out for delivery → delivered timeline.
class ParcelTrackingCard extends StatelessWidget {
  final Parcel parcel;
  final VoidCallback? onTap;

  const ParcelTrackingCard({super.key, required this.parcel, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg.r),
      child: Container(
        decoration: AppDecorations.card(context.colors),
        padding: EdgeInsets.all(AppSpacing.md.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ParcelSummary(parcel: parcel),
            SizedBox(height: AppSpacing.lg.h),
            VerticalTimeline(steps: parcel.timeline),
          ],
        ),
      ),
    );
  }
}
