import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/c2c_parcel_quote.dart';
import 'parcel_price_breakdown.dart';
import 'subscription_discount_banner.dart';

/// A priced parcel: the plan banner (only when a plan applied), the payment
/// summary, and the button that carries the price on to the details step.
/// Without a `quote_token` the price can't be booked, so the button is off.
class ParcelQuoteSummary extends StatelessWidget {
  final C2cParcelQuote quote;
  final VoidCallback onConfirm;

  const ParcelQuoteSummary({
    super.key,
    required this.quote,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppliedParcelSubscription? applied = quote.appliedSubscription;
    final double? distanceKm = quote.distanceKm;
    final int? minutes = quote.estimatedDeliveryMinutes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (applied != null) ...<Widget>[
          SubscriptionDiscountBanner(
            remainingDeliveries: applied.remainingDeliveries,
          ),
          SizedBox(height: AppSpacing.md.h),
        ],
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                Strings.sendParcelSummaryTitle,
                style: AppTextStyles.title(color: c.textPrimary),
              ),
            ),
            if (distanceKm != null)
              Text(
                Strings.sendParcelDistance(formatAmount(distanceKm)),
                style: AppTextStyles.caption(color: c.textSecondary),
              ),
          ],
        ),
        SizedBox(height: AppSpacing.sm.h),
        ParcelPriceBreakdown(
          baseTotalFee: quote.baseTotalFee,
          subscriptionDiscount: applied == null
              ? null
              : quote.subscriptionDiscount,
          totalFee: quote.totalFee,
          currency: quote.currency,
        ),
        SizedBox(height: AppSpacing.sm.h),
        if (minutes != null)
          Row(
            children: <Widget>[
              Icon(Icons.schedule, size: 16.r, color: c.secondary),
              SizedBox(width: AppSpacing.xs.w),
              Text(
                Strings.sendParcelEta('$minutes'),
                style: AppTextStyles.caption(color: c.textPrimary),
              ),
            ],
          ),
        Text(
          Strings.sendParcelQuoteHeld,
          style: AppTextStyles.caption(color: c.textSecondary),
        ),
        SizedBox(height: AppSpacing.lg.h),
        AppButton(
          btnText: Strings.sendParcelConfirmButton,
          onPressed: quote.quoteToken == null ? null : onConfirm,
        ),
      ],
    );
  }
}
