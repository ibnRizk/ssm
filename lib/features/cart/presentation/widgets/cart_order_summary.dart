import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/values/strings.dart';

/// Subtotal → delivery-fee highlight → bold total. The total is summed here
/// rather than passed pre-added, so it can never drift out of sync with its
/// inputs. The cart endpoints don't quote a delivery fee — it depends on the
/// address and is settled at checkout — so while [deliveryFee] is null the
/// highlight says so and the total excludes it.
class CartOrderSummary extends StatelessWidget {
  final double subtotal;
  final double? deliveryFee;

  const CartOrderSummary({super.key, required this.subtotal, this.deliveryFee});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final double? fee = deliveryFee;
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
              formatSar(subtotal),
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
                child: Text(
                  Strings.orderConfirmationDeliveryFeeLabel,
                  style: AppTextStyles.body(color: Colors.white),
                ),
              ),
              SizedBox(width: AppSpacing.sm.w),
              Flexible(
                child: Text(
                  fee == null
                      ? Strings.cartDeliveryFeeAtCheckout
                      : formatSar(fee),
                  textAlign: TextAlign.end,
                  style: fee == null
                      ? AppTextStyles.body(color: c.secondary)
                      : AppTextStyles.h2(color: c.secondary),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md.h),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                fee == null
                    ? Strings.cartTotalBeforeDelivery
                    : Strings.cartTotalLabel,
                style: AppTextStyles.title(color: c.textPrimary),
              ),
            ),
            Text(
              formatSar(subtotal + (fee ?? 0)),
              style: AppTextStyles.h2(color: c.secondary),
            ),
          ],
        ),
      ],
    );
  }
}
