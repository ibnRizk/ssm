import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/store.dart';
import '../utils/store_labels.dart';

/// A single store in a list — Home's preview and the stores screen. The
/// rating pill floats over the card's top edge; a store without ratings
/// shows "New" there instead of a misleading 0.0.
class StoreCard extends StatelessWidget {
  final Store store;
  final VoidCallback? onTap;

  const StoreCard({super.key, required this.store, this.onTap});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final String? subtitle = store.subtitle;
    final String? deliveryTime = store.deliveryTimeLabel;
    final String? feeLabel = store.deliveryFeeLabel;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            width: double.infinity,
            decoration: AppDecorations.card(c),
            padding: EdgeInsets.all(AppSpacing.md.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppNetworkImage(
                  url: store.logoUrl,
                  width: 76.r,
                  height: 76.r,
                  borderRadius: BorderRadius.circular(AppRadius.lg.r),
                  fallback: ColoredBox(
                    color: c.secondaryLight,
                    child: Icon(
                      Icons.storefront_outlined,
                      color: c.secondary,
                      size: 32.r,
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.sm.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        store.name,
                        style: AppTextStyles.title(color: c.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...<Widget>[
                        SizedBox(height: AppSpacing.xxs.h),
                        Text(
                          subtitle,
                          style: AppTextStyles.caption(color: c.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (deliveryTime != null) ...<Widget>[
                        SizedBox(height: 2.h),
                        Text(
                          deliveryTime,
                          style: AppTextStyles.caption(color: c.textSecondary),
                        ),
                      ],
                      SizedBox(height: AppSpacing.xs.h),
                      Row(
                        children: <Widget>[
                          if (feeLabel != null)
                            Flexible(
                              child: Text(
                                feeLabel,
                                style: AppTextStyles.label(color: c.secondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (store.isOpen == false) ...<Widget>[
                            if (feeLabel != null)
                              SizedBox(width: AppSpacing.xs.w),
                            _Pill(
                              label: Strings.storeClosedBadge,
                              background: c.errorLight,
                              foreground: c.error,
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
            child: _RatingPill(store: store),
          ),
        ],
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  final Store store;

  const _RatingPill({required this.store});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: AppShadows.card,
      ),
      child: store.hasRating
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.star_rounded, color: c.secondary, size: 14.r),
                SizedBox(width: 2.w),
                Text(
                  store.rating.toStringAsFixed(1),
                  style: AppTextStyles.label(color: c.secondary),
                ),
              ],
            )
          : Text(
              Strings.storeNewBadge,
              style: AppTextStyles.label(color: c.secondary),
            ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _Pill({
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(label, style: AppTextStyles.label(color: foreground)),
    );
  }
}
