import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/error_text.dart';
import '../../../../core/widgets/no_data_found.dart';
import '../../domain/entities/subscription_plan.dart';
import '../cubit/subscriptions_cubit.dart';
import '../cubit/subscriptions_state.dart';
import '../utils/plan_labels.dart';
import 'subscription_plan_list.dart';

/// The selected zone's plans. Rebuilds only when the plans or the purchase
/// status change — not when, say, the banner refreshes.
class SubscriptionPlansSection extends StatelessWidget {
  const SubscriptionPlansSection({super.key});

  /// Roughly two cards tall, so switching zones doesn't collapse the page.
  static const double _placeholderHeight = 180;

  Future<void> _confirmAndSubscribe(
    BuildContext context,
    SubscriptionPlan plan,
  ) async {
    final SubscriptionsCubit cubit = context.read<SubscriptionsCubit>();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(Strings.subscriptionsConfirmTitle(plan.name)),
        content: Text(
          Strings.subscriptionsConfirmMessage(
            plan.deliveriesCount,
            plan.priceLabel,
            plan.currencyLabel,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(Strings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(Strings.subscriptionsSubscribeButton),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await cubit.subscribe(plan.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      SubscriptionsCubit,
      SubscriptionsState,
      (PlansStatus, PurchaseStatus)?
    >(
      selector: (SubscriptionsState state) =>
          state is SubscriptionsLoaded ? (state.plans, state.purchase) : null,
      builder: (BuildContext context, (PlansStatus, PurchaseStatus)? slice) {
        if (slice == null) return const SizedBox.shrink();
        final (PlansStatus plans, PurchaseStatus purchase) = slice;
        return switch (plans) {
          PlansLoading() => SizedBox(
            height: _placeholderHeight.h,
            child: const Center(child: CircularProgressIndicator()),
          ),
          PlansError(:final failure) => ErrorText(
            message: failure.userMessage,
            margin: EdgeInsets.symmetric(vertical: AppSpacing.lg.h),
            onRetry: () => context.read<SubscriptionsCubit>().retryPlans(),
          ),
          PlansLoaded(plans: final List<SubscriptionPlan> list)
              when list.isEmpty =>
            SizedBox(
              height: _placeholderHeight.h,
              child: NoDataFound(text: Strings.subscriptionsNoPlans),
            ),
          PlansLoaded(
            plans: final List<SubscriptionPlan> list,
            :final bestValueId,
          ) =>
            SubscriptionPlanList(
              plans: list,
              bestValueId: bestValueId,
              purchasingPlanId: purchase is PurchaseInProgress
                  ? purchase.planId
                  : null,
              onSelected: (SubscriptionPlan plan) =>
                  _confirmAndSubscribe(context, plan),
            ),
        };
      },
    );
  }
}
