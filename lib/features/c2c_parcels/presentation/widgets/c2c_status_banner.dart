import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/c2c_parcel_status.dart';
import '../utils/c2c_parcel_labels.dart';

/// The parcel's status at a glance: headline, what it means, the
/// reference, the viewer's role, and the ETA when the server gives one.
class C2cStatusBanner extends StatelessWidget {
  final C2cParcelStatus status;
  final String reference;
  final C2cViewerRole role;
  final int? etaMinutes;

  const C2cStatusBanner({
    super.key,
    required this.status,
    required this.reference,
    required this.role,
    this.etaMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final (
      Color background,
      Color foreground,
      IconData icon,
    ) = switch (status.tone) {
      C2cStatusTone.success => (c.successLight, c.success, Icons.check_circle),
      C2cStatusTone.problem => (c.errorLight, c.error, Icons.error_outline),
      C2cStatusTone.warning => (
        c.warningLight,
        c.warning,
        Icons.keyboard_return,
      ),
      C2cStatusTone.progress => (
        c.primary,
        Colors.white,
        status.isSearchingForDriver
            ? Icons.person_search_outlined
            : Icons.local_shipping_outlined,
      ),
    };
    final int? eta = etaMinutes;
    return Container(
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: foreground, size: 28.r),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  status.title,
                  style: AppTextStyles.title(color: foreground),
                ),
                SizedBox(height: 2.h),
                Text(
                  status.description,
                  style: AppTextStyles.caption(
                    color: foreground.withValues(alpha: 0.85),
                  ),
                ),
                if (eta != null && !status.isTerminal) ...<Widget>[
                  SizedBox(height: AppSpacing.xs.h),
                  Text(
                    Strings.c2cTrackingEta('$eta'),
                    style: AppTextStyles.titleSmall(color: foreground),
                  ),
                ],
                SizedBox(height: AppSpacing.xs.h),
                Text(
                  '$reference · ${role == C2cViewerRole.sender ? Strings.c2cTrackingRoleSender : Strings.c2cTrackingRoleRecipient}',
                  style: AppTextStyles.caption(
                    color: foreground.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
