import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// A single store in the restaurants list. [badgeLabel] is optional — pass it
/// to show a pill (e.g. "Today's offer") next to the delivery-fee text, as
/// on the second card in the design.
class RestaurantCard extends StatelessWidget {
  final String name;
  final List<String> categories;
  final String etaLabel;
  final String deliveryFeeLabel;
  final double rating;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String? badgeLabel;
  final VoidCallback? onTap;

  const RestaurantCard({
    super.key,
    required this.name,
    required this.categories,
    required this.etaLabel,
    required this.deliveryFeeLabel,
    required this.rating,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    this.badgeLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            width: double.infinity,
            decoration: AppDecorations.card(),
            padding: EdgeInsets.all(AppSpacing.md.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 76.r,
                  height: 76.r,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(AppRadius.lg.r),
                  ),
                  child: Icon(icon, color: iconColor, size: 32.r),
                ),
                SizedBox(width: AppSpacing.sm.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        name,
                        style: AppTextStyles.title(color: c.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppSpacing.xxs.h),
                      Text(
                        categories.join('  •  '),
                        style: AppTextStyles.caption(color: c.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        etaLabel,
                        style: AppTextStyles.caption(color: c.textSecondary),
                      ),
                      SizedBox(height: AppSpacing.xs.h),
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              deliveryFeeLabel,
                              style: AppTextStyles.label(color: c.secondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (badgeLabel != null) ...<Widget>[
                            SizedBox(width: AppSpacing.xs.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: c.successLight,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                              ),
                              child: Text(
                                badgeLabel!,
                                style: AppTextStyles.label(color: c.success),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          PositionedDirectional(
            top: -10.h,
            end: AppSpacing.md.w,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xs.w,
                vertical: 4.h,
              ),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                boxShadow: AppShadows.card,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.star_rounded, color: c.secondary, size: 14.r),
                  SizedBox(width: 2.w),
                  Text(
                    rating.toStringAsFixed(1),
                    style: AppTextStyles.label(color: c.secondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
