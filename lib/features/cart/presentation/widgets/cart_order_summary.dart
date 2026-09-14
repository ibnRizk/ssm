import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// Placeholder delivery-fee copy — swap for the resolved zone/fee tiers once
/// the pricing feature exists.
const String _placeholderDeliveryFeeLabel = 'رسوم التوصيل · تربة';
const String _placeholderDeliveryFeeNote = 'تختلف حسب منطقتك: 10 / 15 / 20 / 25 ر.س';

/// Subtotal → delivery-fee highlight → bold total. [subtotal] and
/// [deliveryFee] are summed here rather than passed pre-added, so the total
/// can never drift out of sync with its two inputs.
class CartOrderSummary extends StatelessWidget {
  final int subtotal;
  final int deliveryFee;

  const CartOrderSummary({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                Strings.cartProductsValueLabel,
                style: AppTextStyles.body(color: c.textSecondary),
              ),
            ),
            Text(
              '$subtotal ر.س',
              style: AppTextStyles.titleSmall(color: c.textPrimary),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.md.r),
          decoration: BoxDecoration(
            color: c.primary,
            borderRadius: BorderRadius.circular(AppRadius.lg.r),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _placeholderDeliveryFeeLabel,
                      style: AppTextStyles.body(color: Colors.white),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _placeholderDeliveryFeeNote,
                      style: AppTextStyles.caption(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.sm.w),
              Text(
                '$deliveryFee ر.س',
                style: AppTextStyles.h2(color: c.secondary),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md.h),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                Strings.cartTotalLabel,
                style: AppTextStyles.title(color: c.textPrimary),
              ),
            ),
            Text(
              '${subtotal + deliveryFee} ر.س',
              style: AppTextStyles.h2(color: c.secondary),
            ),
          ],
        ),
      ],
    );
  }
}
