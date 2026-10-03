import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/order_quote.dart';
import '../cubit/checkout_state.dart';
import '../utils/checkout_messages.dart';

/// The server's price breakdown — products, delivery, discounts, tax and
/// the total — exactly as quoted. Nothing is added up here: the total is
/// the server's, so it can't drift from what the order will cost.
class OrderConfirmationSummaryCard extends StatelessWidget {
  final CheckoutQuote quote;
  final VoidCallback onRetry;

  const OrderConfirmationSummaryCard({
    super.key,
    required this.quote,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      width: double.infinity,
      decoration: AppDecorations.card(c),
      padding: EdgeInsets.all(AppSpacing.md.r),
      child: switch (quote) {
        CheckoutQuotePending() || CheckoutQuoteLoading() => _Message(
          Strings.checkoutQuoteLoading,
          leading: SizedBox.square(
            dimension: 18.r,
            child: CircularProgressIndicator(strokeWidth: 2.w),
          ),
        ),
        CheckoutQuoteUnavailable(:final issue) => _Message(issue.message),
        CheckoutQuoteError(:final failure) => _Message(
          failure.userMessage,
          action: TextButton(onPressed: onRetry, child: Text(Strings.retry)),
        ),
        CheckoutQuoteReady(:final OrderQuote quote) => _Breakdown(quote),
      },
    );
  }
}

class _Breakdown extends StatelessWidget {
  final OrderQuote quote;

  const _Breakdown(this.quote);

  String _money(double amount) =>
      '${formatAmount(amount)} ${currencySymbol(quote.currency)}';

  String get _freeDeliveryLabel => switch (quote.freeDeliverySource) {
    FreeDeliverySource.coupon => Strings.checkoutFreeDeliveryCoupon,
    FreeDeliverySource.subscription => Strings.checkoutFreeDeliverySubscription,
    FreeDeliverySource.loyalty => Strings.checkoutFreeDeliveryLoyalty,
    null => Strings.checkoutFreeDelivery,
  };

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Column(
      children: <Widget>[
        _SummaryRow(
          label: Strings.cartProductsValueLabel,
          value: _money(quote.subtotal),
        ),
        SizedBox(height: AppSpacing.sm.h),
        _SummaryRow(
          label: Strings.orderConfirmationDeliveryFeeLabel,
          value: quote.freeDelivery
              ? _freeDeliveryLabel
              : _money(quote.deliveryCharge),
          // What it would have cost, struck through.
          struckValue: quote.freeDelivery && quote.originalDeliveryCharge > 0
              ? _money(quote.originalDeliveryCharge)
              : null,
          valueColor: quote.freeDelivery ? c.success : null,
        ),
        if (quote.couponDiscount > 0) ...<Widget>[
          SizedBox(height: AppSpacing.sm.h),
          _SummaryRow(
            label: Strings.checkoutCouponDiscountLabel,
            value: '-${_money(quote.couponDiscount)}',
            valueColor: c.success,
          ),
        ],
        if (quote.tax > 0) ...<Widget>[
          SizedBox(height: AppSpacing.sm.h),
          _SummaryRow(
            label: Strings.checkoutTaxLabel,
            value: _money(quote.tax),
          ),
        ],
        SizedBox(height: AppSpacing.sm.h),
        Divider(color: c.border, height: 1),
        SizedBox(height: AppSpacing.sm.h),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                Strings.cartTotalLabel,
                style: AppTextStyles.title(color: c.textPrimary),
              ),
            ),
            Text(
              _money(quote.total),
              style: AppTextStyles.h2(color: c.secondary),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final String? struckValue;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.struckValue,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(label, style: AppTextStyles.body(color: c.textSecondary)),
        ),
        if (struckValue case final String struck) ...<Widget>[
          Text(
            struck,
            style: AppTextStyles.body(
              color: c.textHint,
            ).copyWith(decoration: TextDecoration.lineThrough),
          ),
          SizedBox(width: AppSpacing.xs.w),
        ],
        Text(
          value,
          style: AppTextStyles.titleSmall(color: valueColor ?? c.textPrimary),
        ),
      ],
    );
  }
}

/// A line of text in place of the breakdown — loading, a missing input, or
/// an error with its retry.
class _Message extends StatelessWidget {
  final String text;
  final Widget? leading;
  final Widget? action;

  const _Message(this.text, {this.leading, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        if (leading case final Widget leading) ...<Widget>[
          leading,
          SizedBox(width: AppSpacing.sm.w),
        ],
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body(color: context.colors.textSecondary),
          ),
        ),
        ?action,
      ],
    );
  }
}
