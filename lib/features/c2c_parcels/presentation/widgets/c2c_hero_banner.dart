import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/brand_wave.dart';

/// The Home entry to door-to-door parcels: a navy-to-deep-navy gradient
/// card with a "new" badge, the pitch, a parcel-and-route illustration
/// built from icons, and two calls to action.
class C2cHeroBanner extends StatelessWidget {
  final VoidCallback onSend;
  final VoidCallback onMyParcels;

  const C2cHeroBanner({
    super.key,
    required this.onSend,
    required this.onMyParcels,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: <Color>[c.primary, c.primaryDark],
          ),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: -AppSpacing.xl.r,
              right: -AppSpacing.xl.r,
              bottom: -AppSpacing.lg.r,
              height: 70.h,
              child: BrandWave(color: c.secondary.withValues(alpha: 0.35)),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.lg.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: c.accent,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                              ),
                              child: Text(
                                Strings.c2cHeroBadge,
                                style: AppTextStyles.label(color: c.primary),
                              ),
                            ),
                            SizedBox(height: AppSpacing.sm.h),
                            Text(
                              Strings.c2cHeroTitle,
                              style: AppTextStyles.h2(color: Colors.white),
                            ),
                            SizedBox(height: AppSpacing.xs.h),
                            Text(
                              Strings.c2cHeroSubtitle,
                              style: AppTextStyles.caption(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm.w),
                      const _Illustration(),
                    ],
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: c.secondary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.sm.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.lg.r,
                              ),
                            ),
                          ),
                          onPressed: onSend,
                          icon: const Icon(Icons.send_rounded, size: 18),
                          label: Text(
                            Strings.c2cHeroButton,
                            style: AppTextStyles.button(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm.w),
                      TextButton(
                        onPressed: onMyParcels,
                        child: Text(
                          Strings.c2cHeroMyParcels,
                          style: AppTextStyles.titleSmall(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A parcel in a soft halo with a little "route" of a pin and a truck —
/// drawn from icons, since the app ships no illustration assets.
class _Illustration extends StatelessWidget {
  const _Illustration();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final double size = 84.r;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Container(
            width: size * 0.66,
            height: size * 0.66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.secondary,
            ),
            child: Icon(
              Icons.inventory_2_rounded,
              color: Colors.white,
              size: size * 0.34,
            ),
          ),
          PositionedDirectional(
            top: 0,
            end: 0,
            child: Icon(Icons.location_on, color: c.accent, size: 22.r),
          ),
          PositionedDirectional(
            bottom: 2,
            start: 0,
            child: Icon(
              Icons.local_shipping_rounded,
              color: Colors.white,
              size: 22.r,
            ),
          ),
        ],
      ),
    );
  }
}
