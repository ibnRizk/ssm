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
import 'subscription_plan_list.dart';

/// The selected zone's door-to-door parcel plans. There's no purchase
/// endpoint for these, so tapping a plan explains how it gets activated.
class ParcelPlansSection extends StatelessWidget {
  const ParcelPlansSection({super.key});

  /// Roughly two cards tall, so switching zones doesn't collapse the page.
  static const double _placeholderHeight = 180;

  Future<void> _showActivationInfo(
    BuildContext context,
    SubscriptionPlan plan,
  ) => showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: Text(plan.name),
      content: Text(Strings.subscriptionsParcelPlanInfo),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(Strings.ok),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SubscriptionsCubit, SubscriptionsState, PlansStatus?>(
      selector: (SubscriptionsState state) =>
          state is SubscriptionsLoaded ? state.parcelPlans : null,
      builder: (BuildContext context, PlansStatus? plans) => switch (plans) {
        null || PlansLoading() => SizedBox(
          height: _placeholderHeight.h,
          child: const Center(child: CircularProgressIndicator()),
        ),
        PlansError(:final failure) => ErrorText(
          message: failure.userMessage,
          margin: EdgeInsets.symmetric(vertical: AppSpacing.lg.h),
          onRetry: () => context.read<SubscriptionsCubit>().retryParcelPlans(),
        ),
        PlansLoaded(plans: final List<SubscriptionPlan> list)
            when list.isEmpty =>
          SizedBox(
            height: _placeholderHeight.h,
            child: NoDataFound(text: Strings.subscriptionsNoParcelPlans),
          ),
        PlansLoaded(
          plans: final List<SubscriptionPlan> list,
          :final bestValueId,
        ) =>
          SubscriptionPlanList(
            plans: list,
            bestValueId: bestValueId,
            onSelected: (SubscriptionPlan plan) =>
                _showActivationInfo(context, plan),
          ),
      },
    );
  }
}
