import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/values/strings.dart';

/// Delivery fee → plan discount → total, as the server quoted them. The
/// total is the server's [totalFee], not summed here: the server owns the
/// pricing and its rounding.
class ParcelPriceBreakdown extends StatelessWidget {
  final double baseTotalFee;

  /// Null hides the discount row — no plan applied.
  final double? subscriptionDiscount;
  final double totalFee;

  /// ISO 4217 code, e.g. `SAR`.
  final String currency;

  const ParcelPriceBreakdown({
    super.key,
    required this.baseTotalFee,
    required this.subscriptionDiscount,
    required this.totalFee,
    required this.currency,
  });

  String _money(double amount) =>
      '${formatAmount(amount)} ${currencySymbol(currency)}';

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final double? discount = subscriptionDiscount;
    return Container(
      width: double.infinity,
      decoration: AppDecorations.card(c),
      padding: EdgeInsets.all(AppSpacing.md.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _Row(
            label: Strings.sendParcelDeliveryFee,
            value: _money(baseTotalFee),
            labelStyle: AppTextStyles.body(color: c.textSecondary),
            valueStyle: AppTextStyles.titleSmall(color: c.textPrimary),
          ),
          if (discount != null) ...<Widget>[
            SizedBox(height: AppSpacing.sm.h),
            _Row(
              label: Strings.sendParcelPlanDiscount,
              value: '-${_money(discount)}',
              labelStyle: AppTextStyles.body(color: c.success),
              valueStyle: AppTextStyles.titleSmall(color: c.success),
            ),
          ],
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
            child: Divider(height: 1, color: c.border),
          ),
          _Row(
            label: Strings.sendParcelTotal,
            value: _money(totalFee),
            labelStyle: AppTextStyles.title(color: c.textPrimary),
            valueStyle: AppTextStyles.h2(color: c.secondary),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle labelStyle;
  final TextStyle valueStyle;

  const _Row({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Text(label, style: labelStyle)),
        SizedBox(width: AppSpacing.sm.w),
        Text(value, style: valueStyle),
      ],
    );
  }
}
