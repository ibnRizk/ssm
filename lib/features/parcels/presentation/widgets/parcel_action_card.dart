import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/brand_wave.dart';

/// The navy "your parcel arrived" card: title/subtitle on the start side, a
/// small parcel-icon badge on the end side, body copy, and a full-width
/// button — with the brand wave washing in from the bottom-left, same
/// physically-anchored treatment as the Home subscription banner.
class ParcelActionCard extends StatelessWidget {
  /// The parcel the button acts on, e.g. `SSM-P2048`.
  final String reference;

  /// A drop-off was already sent — the button then offers to update it.
  final bool locationSent;

  /// Spinner on the button while locating or sending.
  final bool isBusy;
  final VoidCallback onSendLocation;

  const ParcelActionCard({
    super.key,
    required this.reference,
    required this.locationSent,
    required this.isBusy,
    required this.onSendLocation,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl.r),
      child: Container(
        width: double.infinity,
        color: c.primary,
        padding: EdgeInsets.all(AppSpacing.lg.r),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: -AppSpacing.xl.r,
              right: -AppSpacing.xl.r,
              bottom: -AppSpacing.lg.r,
              height: 90.h,
              child: BrandWave(color: c.secondary),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            Strings.parcelsActionTitle,
                            style: AppTextStyles.title(color: Colors.white),
                          ),
                          SizedBox(height: AppSpacing.xxs.h),
                          Text(
                            Strings.parcelsShipmentReference(reference),
                            style: AppTextStyles.caption(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm.w),
                    Container(
                      width: 36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        color: c.secondary,
                        borderRadius: BorderRadius.circular(AppRadius.sm.r),
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg.h),
                Text(
                  locationSent
                      ? Strings.parcelsActionBodySent
                      : Strings.parcelsActionBody,
                  style: AppTextStyles.body(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                SizedBox(height: AppSpacing.lg.h),
                AppButton(
                  btnText: locationSent
                      ? Strings.parcelsActionButtonUpdate
                      : Strings.parcelsActionButton,
                  isLoading: isBusy,
                  onPressed: onSendLocation,
                ),
                // The wave is a Positioned overlay, not Column flow — this
                // reserves clear navy space below the button so the button
                // doesn't paint over it (it's drawn after, i.e. on top).
                SizedBox(height: 80.h),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
