import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../cubit/subscriptions_state.dart';

/// Two-segment pill: store-delivery plans vs. door-to-door parcel plans.
class SubscriptionsProductToggle extends StatelessWidget {
  final SubscriptionProduct selected;
  final ValueChanged<SubscriptionProduct> onChanged;

  const SubscriptionsProductToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: <Widget>[
          for (final SubscriptionProduct product in SubscriptionProduct.values)
            Expanded(
              child: _Segment(
                label: switch (product) {
                  SubscriptionProduct.delivery =>
                    Strings.subscriptionsProductDelivery,
                  SubscriptionProduct.parcels =>
                    Strings.subscriptionsProductParcels,
                },
                selected: product == selected,
                onTap: () => onChanged(product),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm.h),
          decoration: BoxDecoration(
            color: selected ? c.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleSmall(
              color: selected ? Colors.white : c.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
