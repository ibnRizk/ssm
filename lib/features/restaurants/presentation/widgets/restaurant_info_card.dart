import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// The white card that floats over the seam between [RestaurantDetailsHeader]
/// and the scrollable body: store name, an "open now" badge, and the
/// rating/eta/fee summary line.
class RestaurantInfoCard extends StatelessWidget {
  final String storeName;
  final double rating;
  final String etaLabel;
  final String deliveryFeeLabel;

  const RestaurantInfoCard({
    super.key,
    required this.storeName,
    required this.rating,
    required this.etaLabel,
    required this.deliveryFeeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      width: double.infinity,
      decoration: AppDecorations.card(),
      padding: EdgeInsets.all(AppSpacing.md.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            storeName,
            style: AppTextStyles.h2(color: c.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppSpacing.xs.h),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm.w,
              vertical: 2.h,
            ),
            decoration: BoxDecoration(
              color: c.successLight,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              Strings.storeDetailsOpenNowBadge,
              style: AppTextStyles.label(color: c.success),
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                Icon(Icons.star_rounded, color: c.secondary, size: 14.r),
                SizedBox(width: 2.w),
                Text(
                  rating.toStringAsFixed(1),
                  style: AppTextStyles.caption(color: c.textSecondary),
                ),
                _Bullet(color: c.textHint),
                Text(
                  etaLabel,
                  style: AppTextStyles.caption(color: c.textSecondary),
                ),
                _Bullet(color: c.textHint),
                Text(
                  deliveryFeeLabel,
                  style: AppTextStyles.caption(color: c.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final Color color;

  const _Bullet({required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs.w),
      child: Text('•', style: TextStyle(color: color, fontSize: 12.sp)),
    );
  }
}
