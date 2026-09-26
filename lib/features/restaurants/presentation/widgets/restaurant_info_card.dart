import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../catalog/domain/entities/store.dart';
import '../../../catalog/presentation/utils/store_labels.dart';

/// The white card that floats over the seam between [RestaurantDetailsHeader]
/// and the scrollable body: store name, an open/closed badge, and the
/// rating/eta/fee summary line. Parts the backend didn't send are left out.
class RestaurantInfoCard extends StatelessWidget {
  final Store store;

  const RestaurantInfoCard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final bool? isOpen = store.isOpen;
    final List<String> facts = <String>[
      if (store.deliveryTimeLabel case final String time) time,
      if (store.deliveryFeeLabel case final String fee) fee,
    ];
    return Container(
      width: double.infinity,
      decoration: AppDecorations.card(c),
      padding: EdgeInsets.all(AppSpacing.md.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            store.name,
            style: AppTextStyles.h2(color: c.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (isOpen != null) ...<Widget>[
            SizedBox(height: AppSpacing.xs.h),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm.w,
                vertical: 2.h,
              ),
              decoration: BoxDecoration(
                color: isOpen ? c.successLight : c.errorLight,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                isOpen
                    ? Strings.storeDetailsOpenNowBadge
                    : Strings.storeClosedBadge,
                style: AppTextStyles.label(color: isOpen ? c.success : c.error),
              ),
            ),
          ],
          SizedBox(height: AppSpacing.sm.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                if (store.hasRating) ...<Widget>[
                  Icon(Icons.star_rounded, color: c.secondary, size: 14.r),
                  SizedBox(width: 2.w),
                  Text(
                    store.rating.toStringAsFixed(1),
                    style: AppTextStyles.caption(color: c.textSecondary),
                  ),
                ] else
                  Text(
                    Strings.storeNewBadge,
                    style: AppTextStyles.caption(color: c.textSecondary),
                  ),
                for (final String fact in facts) ...<Widget>[
                  _Bullet(color: c.textHint),
                  Text(
                    fact,
                    style: AppTextStyles.caption(color: c.textSecondary),
                  ),
                ],
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
      child: Text(
        '•',
        style: TextStyle(color: color, fontSize: 12.sp),
      ),
    );
  }
}
