import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/values/strings.dart';

/// Products value → delivery fee → bold total, in one white card. [total] is
/// summed here rather than passed pre-added, so it can never drift out of
/// sync with the two rows above it.
class OrderConfirmationSummaryCard extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;

  const OrderConfirmationSummaryCard({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      width: double.infinity,
      decoration: AppDecorations.card(c),
      padding: EdgeInsets.all(AppSpacing.md.r),
      child: Column(
        children: <Widget>[
          _SummaryRow(
            label: Strings.cartProductsValueLabel,
            amount: subtotal,
            c: c,
          ),
          SizedBox(height: AppSpacing.sm.h),
          _SummaryRow(
            label: Strings.orderConfirmationDeliveryFeeLabel,
            amount: deliveryFee,
            c: c,
          ),
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
                formatSar(subtotal + deliveryFee),
                style: AppTextStyles.h2(color: c.secondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final AppColors c;

  const _SummaryRow({
    required this.label,
    required this.amount,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(label, style: AppTextStyles.body(color: c.textSecondary)),
        ),
        Text(
          formatSar(amount),
          style: AppTextStyles.titleSmall(color: c.textPrimary),
        ),
      ],
    );
  }
}
