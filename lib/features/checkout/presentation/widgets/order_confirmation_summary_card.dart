import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/values/strings.dart';

/// Products value → delivery fee → bold total, in one white card. The total
/// is summed here rather than passed pre-added, so it can never drift out
/// of sync with the rows above it.
class OrderConfirmationSummaryCard extends StatelessWidget {
  final double subtotal;

  /// Null until the server computes it on placing the order — the total
  /// is then labelled as excluding delivery.
  final double? deliveryFee;

  const OrderConfirmationSummaryCard({
    super.key,
    required this.subtotal,
    this.deliveryFee,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final double? deliveryFee = this.deliveryFee;
    return Container(
      width: double.infinity,
      decoration: AppDecorations.card(c),
      padding: EdgeInsets.all(AppSpacing.md.r),
      child: Column(
        children: <Widget>[
          _SummaryRow(
            label: Strings.cartProductsValueLabel,
            value: formatSar(subtotal),
            c: c,
          ),
          SizedBox(height: AppSpacing.sm.h),
          _SummaryRow(
            label: Strings.orderConfirmationDeliveryFeeLabel,
            value: deliveryFee == null
                ? Strings.checkoutDeliveryFeeOnConfirm
                : formatSar(deliveryFee),
            c: c,
          ),
          SizedBox(height: AppSpacing.sm.h),
          Divider(color: c.border, height: 1),
          SizedBox(height: AppSpacing.sm.h),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  deliveryFee == null
                      ? Strings.cartTotalBeforeDelivery
                      : Strings.cartTotalLabel,
                  style: AppTextStyles.title(color: c.textPrimary),
                ),
              ),
              Text(
                formatSar(subtotal + (deliveryFee ?? 0)),
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
  final String value;
  final AppColors c;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(label, style: AppTextStyles.body(color: c.textSecondary)),
        ),
        Text(value, style: AppTextStyles.titleSmall(color: c.textPrimary)),
      ],
    );
  }
}
