import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_wave.dart';

/// The navy hero block behind the overlapping [RestaurantInfoCard] — store
/// name/subtitle over a bottom-anchored [BrandWave], same physically-anchored
/// treatment as the Home subscription banner and the Parcels action card.
class RestaurantDetailsHeader extends StatelessWidget {
  final String storeName;
  final String storeSubtitle;
  final VoidCallback? onBack;

  static const double height = 168;

  const RestaurantDetailsHeader({
    super.key,
    required this.storeName,
    required this.storeSubtitle,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return ClipRect(
      child: Container(
        width: double.infinity,
        height: height.h,
        color: c.primary,
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screen.w,
          AppSpacing.lg.h,
          AppSpacing.screen.w,
          AppSpacing.xxl.h,
        ),
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
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(
                        alpha: 0.15,
                      ),
                    ),
                    child: Transform.flip(
                      flipX:
                          Directionality.of(context) ==
                          TextDirection.rtl,
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18.r,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.lg.h),
                Text(
                  storeName,
                  style: AppTextStyles.h1(
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xxs.h),
                Text(
                  storeSubtitle,
                  style: AppTextStyles.caption(
                    color: Colors.white.withValues(
                      alpha: 0.8,
                    ),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
