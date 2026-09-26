import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/order_tracking.dart';

/// What was ordered, and the server's own delivery fee and total.
class OrderTrackingItemsCard extends StatelessWidget {
  final List<OrderLine> lines;
  final double? deliveryCharge;
  final double? orderAmount;

  const OrderTrackingItemsCard({
    super.key,
    required this.lines,
    this.deliveryCharge,
    this.orderAmount,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final double? deliveryCharge = this.deliveryCharge;
    final double? orderAmount = this.orderAmount;
    return Container(
      width: double.infinity,
      decoration: AppDecorations.card(c),
      padding: EdgeInsets.all(AppSpacing.md.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            Strings.orderTrackingItemsTitle,
            style: AppTextStyles.title(color: c.textPrimary),
          ),
          SizedBox(height: AppSpacing.sm.h),
          for (final OrderLine line in lines)
            _Row(
              label: '${line.quantity} × ${line.name}',
              value: formatSar(line.lineTotal),
            ),
          if (deliveryCharge != null)
            _Row(
              label: Strings.orderConfirmationDeliveryFeeLabel,
              value: formatSar(deliveryCharge),
            ),
          if (orderAmount != null) ...<Widget>[
            Divider(color: c.border, height: AppSpacing.md.h),
            _Row(
              label: Strings.cartTotalLabel,
              value: formatSar(orderAmount),
              emphasized: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;

  const _Row({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: emphasized
                  ? AppTextStyles.title(color: c.textPrimary)
                  : AppTextStyles.body(color: c.textSecondary),
            ),
          ),
          Text(
            value,
            style: emphasized
                ? AppTextStyles.title(color: c.secondary)
                : AppTextStyles.titleSmall(color: c.textPrimary),
          ),
        ],
      ),
    );
  }
}
