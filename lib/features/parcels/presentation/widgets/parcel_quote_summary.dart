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
/// summary, and the confirm button.
///
/// Creating the parcel isn't wired yet, so the button stays disabled with a
/// note saying so.
class ParcelQuoteSummary extends StatelessWidget {
  final C2cParcelQuote quote;

  const ParcelQuoteSummary({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppliedParcelSubscription? applied = quote.appliedSubscription;
    final double? distanceKm = quote.distanceKm;
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
        Text(
          Strings.sendParcelQuoteHeld,
          style: AppTextStyles.caption(color: c.textSecondary),
        ),
        SizedBox(height: AppSpacing.lg.h),
        AppButton(btnText: Strings.sendParcelConfirmButton, onPressed: null),
        SizedBox(height: AppSpacing.xs.h),
        Text(
          Strings.sendParcelConfirmSoon,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption(color: c.textHint),
        ),
      ],
    );
  }
}
