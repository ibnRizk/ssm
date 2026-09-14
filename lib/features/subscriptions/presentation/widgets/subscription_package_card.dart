import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// One subscription plan. [featured] switches the whole visual treatment —
/// white card with a navy price vs. a navy card with a gold border, an
/// overlapping badge, and an orange price — rather than layering optional
/// params onto one shared look, since the two variants share almost nothing
/// visually beyond the row layout.
class SubscriptionPackageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int price;
  final bool featured;
  final VoidCallback? onTap;

  const SubscriptionPackageCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    this.featured = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return featured ? _buildFeatured(context) : _buildStandard(context);
  }

  Widget _buildStandard(BuildContext context) {
    final AppColors c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: AppDecorations.card(),
        padding: EdgeInsets.all(AppSpacing.md.r),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: AppTextStyles.titleSmall(color: c.textPrimary),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption(color: c.textSecondary),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.sm.w),
            _PriceText(price: price, priceColor: c.primary, currencyColor: c.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatured(BuildContext context) {
    final AppColors c = context.colors;
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.md.r),
            decoration: BoxDecoration(
              color: c.primary,
              borderRadius: BorderRadius.circular(AppRadius.lg.r),
              border: Border.all(color: c.accent, width: 2),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: AppTextStyles.titleSmall(color: Colors.white),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: AppTextStyles.caption(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.sm.w),
                _PriceText(
                  price: price,
                  priceColor: c.secondary,
                  currencyColor: c.secondary,
                ),
              ],
            ),
          ),
        ),
        PositionedDirectional(
          top: -12.h,
          start: AppSpacing.md.w,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm.w,
              vertical: 4.h,
            ),
            decoration: BoxDecoration(
              color: c.accent,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              Strings.subscriptionsBestValueBadge,
              style: AppTextStyles.label(color: c.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class _PriceText extends StatelessWidget {
  final int price;
  final Color priceColor;
  final Color currencyColor;

  const _PriceText({
    required this.price,
    required this.priceColor,
    required this.currencyColor,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(text: '$price', style: AppTextStyles.h1(color: priceColor)),
          TextSpan(text: ' ر.س', style: AppTextStyles.caption(color: currencyColor)),
        ],
      ),
    );
  }
}
