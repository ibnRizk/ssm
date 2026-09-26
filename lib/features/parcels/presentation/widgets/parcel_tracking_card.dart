import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/vertical_timeline.dart';
import '../../domain/entities/parcel.dart';
import '../utils/parcel_labels.dart';

/// A parcel that reached the warehouse: reference, freshness, payment, and
/// the warehouse → out for delivery → delivered timeline.
class ParcelTrackingCard extends StatelessWidget {
  final Parcel parcel;

  const ParcelTrackingCard({super.key, required this.parcel});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final DateTime? updatedAt = parcel.updatedAt;
    return Container(
      decoration: AppDecorations.card(c),
      padding: EdgeInsets.all(AppSpacing.md.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  Strings.parcelsShipmentReference(parcel.reference),
                  style: AppTextStyles.titleSmall(color: c.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (updatedAt != null)
                Text(
                  parcelUpdatedLabel(
                    updatedAt,
                    DateTime.now(),
                    Localizations.localeOf(context).languageCode,
                  ),
                  style: AppTextStyles.caption(color: c.textSecondary),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.xs.h),
          Wrap(
            spacing: AppSpacing.xs.w,
            runSpacing: AppSpacing.xxs.h,
            children: <Widget>[
              _Chip(
                label: parcel.paymentLabel,
                background: parcel.paymentType == ParcelPaymentType.cod
                    ? c.secondaryLight
                    : c.successLight,
                foreground: parcel.paymentType == ParcelPaymentType.cod
                    ? c.secondaryDark
                    : c.success,
              ),
              if (parcel.deliveryFee == 0)
                _Chip(
                  label: Strings.parcelsFreeDelivery,
                  background: c.primaryLight,
                  foreground: c.primary,
                ),
            ],
          ),
          SizedBox(height: AppSpacing.lg.h),
          VerticalTimeline(steps: parcel.timeline),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _Chip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(label, style: AppTextStyles.label(color: foreground)),
    );
  }
}
