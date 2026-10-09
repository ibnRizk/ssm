import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../domain/entities/subscription_plan.dart';
import '../utils/plan_labels.dart';
import 'subscription_package_card.dart';

/// A zone's plans as cards, the best-value one featured. Shared by the
/// store-delivery and the parcel plans.
class SubscriptionPlanList extends StatelessWidget {
  final List<SubscriptionPlan> plans;
  final int? bestValueId;

  /// Non-null while a purchase runs — every card is disabled meanwhile.
  final int? purchasingPlanId;
  final ValueChanged<SubscriptionPlan> onSelected;

  const SubscriptionPlanList({
    super.key,
    required this.plans,
    required this.bestValueId,
    required this.onSelected,
    this.purchasingPlanId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < plans.length; i++) ...<Widget>[
          if (i > 0)
            // Extra room above the featured card for its overlapping badge.
            SizedBox(
              height:
                  (plans[i].id == bestValueId ? AppSpacing.lg : AppSpacing.md)
                      .h,
            ),
          SubscriptionPackageCard(
            key: ValueKey<int>(plans[i].id),
            title: plans[i].name,
            subtitle: plans[i].summary,
            price: plans[i].priceLabel,
            currency: plans[i].currencyLabel,
            featured: plans[i].id == bestValueId,
            isLoading: plans[i].id == purchasingPlanId,
            onTap: purchasingPlanId == null ? () => onSelected(plans[i]) : null,
          ),
        ],
      ],
    );
  }
}
