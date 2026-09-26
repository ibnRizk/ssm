import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/error_text.dart';
import '../../domain/entities/active_subscription.dart';
import '../../domain/entities/delivery_zone.dart';
import '../cubit/subscriptions_cubit.dart';
import '../cubit/subscriptions_state.dart';
import '../widgets/active_subscription_banner.dart';
import '../widgets/subscription_plans_section.dart';
import '../widgets/subscriptions_area_card.dart';
import '../widgets/subscriptions_footer_note.dart';
import '../widgets/subscriptions_header.dart';

/// Subscriptions tab body. The bottom navigation bar and its Scaffold live
/// in [MainScaffold] — this widget is only the scrollable content for that
/// tab. Expects a [SubscriptionsCubit] above it (provided at the route).
class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: _PurchaseResultListener(
        child: RefreshIndicator(
          onRefresh: () => context.read<SubscriptionsCubit>().load(),
          child: SingleChildScrollView(
            // Pull-to-refresh must work even on a short page.
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screen.w,
              AppSpacing.lg.h,
              AppSpacing.screen.w,
              AppSpacing.xxl.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SubscriptionsHeader(),
                SizedBox(height: AppSpacing.lg.h),
                const _SubscriptionsBody(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Switches between loading / error / content. Rebuilds only when that
/// top-level phase changes; each loaded section selects its own slice.
class _SubscriptionsBody extends StatelessWidget {
  const _SubscriptionsBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionsCubit, SubscriptionsState>(
      buildWhen: (SubscriptionsState previous, SubscriptionsState current) =>
          previous.runtimeType != current.runtimeType,
      builder: (BuildContext context, SubscriptionsState state) =>
          switch (state) {
            SubscriptionsLoaded() => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const _ActiveBanner(),
                const _AreaCard(),
                SizedBox(height: AppSpacing.lg.h),
                const SubscriptionPlansSection(),
                SizedBox(height: AppSpacing.lg.h),
                const SubscriptionsFooterNote(),
              ],
            ),
            SubscriptionsError(:final failure) => ErrorText(
              message: failure.userMessage,
              onRetry: () => context.read<SubscriptionsCubit>().load(),
            ),
            SubscriptionsInitial() || SubscriptionsLoading() => Padding(
              padding: EdgeInsets.only(top: AppSpacing.xxl.h),
              child: const Center(child: CircularProgressIndicator()),
            ),
          },
    );
  }
}

class _ActiveBanner extends StatelessWidget {
  const _ActiveBanner();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      SubscriptionsCubit,
      SubscriptionsState,
      ActiveSubscription?
    >(
      selector: (SubscriptionsState state) =>
          state is SubscriptionsLoaded ? state.current : null,
      builder: (BuildContext context, ActiveSubscription? current) =>
          current == null
          ? const SizedBox.shrink()
          : Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md.h),
              child: ActiveSubscriptionBanner(subscription: current),
            ),
    );
  }
}

class _AreaCard extends StatelessWidget {
  const _AreaCard();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      SubscriptionsCubit,
      SubscriptionsState,
      (List<DeliveryZone>, int?)
    >(
      selector: (SubscriptionsState state) => state is SubscriptionsLoaded
          ? (state.zones, state.selectedZoneId)
          : (const <DeliveryZone>[], null),
      builder: (BuildContext context, (List<DeliveryZone>, int?) slice) =>
          SubscriptionsAreaCard(
            zones: slice.$1,
            selectedZoneId: slice.$2,
            onSelected: (int zoneId) =>
                context.read<SubscriptionsCubit>().selectZone(zoneId),
          ),
    );
  }
}

/// One-shot feedback for a purchase intent. Never rebuilds [child].
class _PurchaseResultListener extends StatelessWidget {
  final Widget child;

  const _PurchaseResultListener({required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubscriptionsCubit, SubscriptionsState>(
      listenWhen: (SubscriptionsState previous, SubscriptionsState current) =>
          current is SubscriptionsLoaded &&
          (previous is! SubscriptionsLoaded ||
              previous.purchase != current.purchase),
      listener: (BuildContext context, SubscriptionsState state) {
        switch ((state as SubscriptionsLoaded).purchase) {
          case PurchasePendingApproval():
            showAppSnackBar(
              context: context,
              message: Strings.subscriptionsPendingApproval,
              type: ToastType.success,
              duration: const Duration(seconds: 5),
            );
          case PurchaseFailed(:final failure):
            showAppSnackBar(
              context: context,
              message: failure.userMessage,
              type: ToastType.error,
            );
          case PurchaseIdle() || PurchaseInProgress():
            break;
        }
      },
      child: child,
    );
  }
}
