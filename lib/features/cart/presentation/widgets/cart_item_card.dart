import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/cart.dart';

/// A single cart row: image, name, store and line total, a +/- stepper and
/// a remove button. While [busy] (a change to this line is in flight) the
/// controls are disabled and a spinner replaces the quantity.
class CartItemCard extends StatelessWidget {
  final CartLine line;
  final bool busy;
  final VoidCallback onIncrement;

  /// At quantity 1 this removes the line.
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.line,
    required this.busy,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final String? storeName = line.storeName;
    return Container(
      width: double.infinity,
      decoration: AppDecorations.card(c),
      padding: EdgeInsets.all(AppSpacing.md.r),
      child: Row(
        children: <Widget>[
          AppNetworkImage(
            url: line.imageUrl,
            width: 56.r,
            height: 56.r,
            borderRadius: BorderRadius.circular(AppRadius.md.r),
            fallback: ColoredBox(
              color: c.secondaryLight,
              child: Icon(
                Icons.fastfood_outlined,
                color: c.secondary,
                size: 24.r,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  line.name,
                  style: AppTextStyles.titleSmall(color: c.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (storeName != null) ...<Widget>[
                  SizedBox(height: 2.h),
                  Text(
                    storeName,
                    style: AppTextStyles.caption(color: c.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: AppSpacing.xxs.h),
                Text(
                  formatSar(line.lineTotal),
                  style: AppTextStyles.titleSmall(color: c.secondaryDark),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              IconButton(
                onPressed: busy ? null : onRemove,
                tooltip: Strings.cartRemoveItem,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.delete_outline,
                  size: 20.r,
                  color: busy ? c.textHint : c.error,
                ),
              ),
              _QuantityStepper(
                quantity: line.quantity,
                busy: busy,
                onIncrement: onIncrement,
                onDecrement: onDecrement,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final bool busy;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantityStepper({
    required this.quantity,
    required this.busy,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs.w),
      decoration: BoxDecoration(
        color: c.secondaryLight,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _StepperIcon(icon: Icons.add, onTap: busy ? null : onIncrement),
          SizedBox(
            width: 28.w,
            child: busy
                ? Center(
                    child: SizedBox.square(
                      dimension: 14.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: c.secondary,
                      ),
                    ),
                  )
                : Text(
                    '$quantity',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleSmall(color: c.secondaryDark),
                  ),
          ),
          _StepperIcon(icon: Icons.remove, onTap: busy ? null : onDecrement),
        ],
      ),
    );
  }
}

class _StepperIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xs.h),
        child: Icon(
          icon,
          size: 16.r,
          color: onTap == null ? c.textHint : c.secondary,
        ),
      ),
    );
  }
}
