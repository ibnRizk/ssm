import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_format.dart';
import '../../domain/entities/c2c_parcel.dart';
import '../utils/c2c_parcel_labels.dart';

/// One parcel in a list: title, reference, the other side, the status
/// chip and — when the viewer sees it — the price.
class C2cParcelCard extends StatelessWidget {
  final C2cParcelSummary parcel;
  final VoidCallback onTap;

  const C2cParcelCard({super.key, required this.parcel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final (Color chipBackground, Color chipText) = switch (parcel.status.tone) {
      C2cStatusTone.success => (c.successLight, c.success),
      C2cStatusTone.problem => (c.errorLight, c.error),
      C2cStatusTone.warning => (c.warningLight, c.warning),
      C2cStatusTone.progress => (c.primaryLight, c.primary),
    };
    final double? fee = parcel.totalFee;
    final DateTime? createdAt = parcel.createdAt;
    final String? counterpart = parcel.counterpartLabel;
    final String? destination = parcel.destinationAddress;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg.r),
      child: Container(
        decoration: AppDecorations.card(c),
        padding: EdgeInsets.all(AppSpacing.md.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    parcel.title ?? parcel.reference,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleSmall(color: c.textPrimary),
                  ),
                ),
                SizedBox(width: AppSpacing.sm.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm.w,
                    vertical: 2.h,
                  ),
                  decoration: BoxDecoration(
                    color: chipBackground,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    parcel.status.title,
                    style: AppTextStyles.label(color: chipText),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xxs.h),
            Text(
              <String>[
                parcel.reference,
                if (createdAt != null)
                  DateFormat(
                    'd MMM',
                    Localizations.localeOf(context).languageCode,
                  ).format(createdAt.toLocal()),
              ].join(' · '),
              style: AppTextStyles.caption(color: c.textSecondary),
            ),
            if (counterpart != null || destination != null) ...<Widget>[
              SizedBox(height: AppSpacing.xs.h),
              Row(
                children: <Widget>[
                  Icon(Icons.place_outlined, size: 16.r, color: c.secondary),
                  SizedBox(width: AppSpacing.xxs.w),
                  Expanded(
                    child: Text(
                      <String?>[
                        counterpart,
                        destination,
                      ].whereType<String>().join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption(color: c.textPrimary),
                    ),
                  ),
                  if (fee != null)
                    Text(
                      '${formatAmount(fee)} ${currencySymbol(parcel.currency)}',
                      style: AppTextStyles.titleSmall(color: c.secondary),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
