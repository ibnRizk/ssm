import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/error_text.dart';
import '../../../../core/widgets/load_more_footer.dart';
import '../../../cart/presentation/widgets/cart_replace_dialog.dart';
import '../../domain/entities/order_list_entry.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';
import '../cubit/reorder_cubit.dart';
import '../cubit/reorder_state.dart';
import '../utils/order_list_labels.dart';
import '../widgets/current_order_card.dart';
import '../widgets/orders_filter_tabs.dart';
import '../widgets/orders_header.dart';
import '../widgets/past_order_card.dart';

/// Orders tab body. The bottom navigation bar and its Scaffold live in
/// [MainScaffold] — this widget is only the scrollable content for that
/// tab. [OrdersCubit] and [ReorderCubit] are provided by the route.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  /// How close to the end of the list the next page starts loading.
  static const double _loadMoreThreshold = 400;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return _ReorderListener(
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => context.read<OrdersCubit>().load(),
          child: NotificationListener<ScrollUpdateNotification>(
            onNotification: (ScrollUpdateNotification notification) {
              if (notification.metrics.extentAfter < _loadMoreThreshold) {
                context.read<OrdersCubit>().loadMore();
              }
              return false;
            },
            child: CustomScrollView(
              // Pull-to-refresh must work even on a short list.
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screen.w,
                    AppSpacing.lg.h,
                    AppSpacing.screen.w,
                    0,
                  ),
                  sliver: SliverList.list(
                    children: <Widget>[
                      BlocSelector<OrdersCubit, OrdersState, int?>(
                        selector: (OrdersState state) => state.totalOrders,
                        builder: (_, int? total) =>
                            OrdersHeader(totalOrders: total),
                      ),
                      SizedBox(height: AppSpacing.lg.h),
                      BlocSelector<OrdersCubit, OrdersState, OrdersFilter>(
                        selector: (OrdersState state) => state.filter,
                        builder: (BuildContext context, OrdersFilter filter) =>
                            OrdersFilterTabs(
                              selected: filter,
                              onSelected: context
                                  .read<OrdersCubit>()
                                  .selectFilter,
                            ),
                      ),
                      SizedBox(height: AppSpacing.sm.h),
                      Divider(color: c.border, height: 1),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screen.w,
                    AppSpacing.lg.h,
                    AppSpacing.screen.w,
                    AppSpacing.xxl.h,
                  ),
                  sliver: const _OrdersBody(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The sections the filter shows. "All" leaves out the current-orders
/// section when there are none.
class _OrdersBody extends StatelessWidget {
  const _OrdersBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (BuildContext context, OrdersState state) =>
          switch (state.filter) {
            OrdersFilter.current => _OrderList(
              section: OrdersSection.running,
              list: state.running,
            ),
            OrdersFilter.past => _OrderList(
              section: OrdersSection.past,
              list: state.past,
            ),
            OrdersFilter.all => SliverMainAxisGroup(
              slivers: <Widget>[
                if (state.running case OrderListLoaded(
                  :final orders,
                ) when orders.isEmpty)
                  const SliverToBoxAdapter()
                else ...<Widget>[
                  _SectionTitle(title: Strings.ordersCurrentSectionTitle),
                  _OrderList(
                    section: OrdersSection.running,
                    list: state.running,
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl.h)),
                ],
                _SectionTitle(
                  title: Strings.ordersPastSectionTitle,
                  trailing: Strings.ordersNewestFirstLabel,
                ),
                _OrderList(section: OrdersSection.past, list: state.past),
              ],
            ),
          },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? trailing;

  const _SectionTitle({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return SliverPadding(
      padding: EdgeInsets.only(bottom: AppSpacing.md.h),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.title(color: c.textPrimary),
              ),
            ),
            if (trailing case final String label)
              Text(label, style: AppTextStyles.caption(color: c.secondary)),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final OrdersSection section;
  final OrderListState list;

  const _OrderList({required this.section, required this.list});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return switch (list) {
      OrderListLoaded(:final orders) when orders.isEmpty => SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xl.h),
          child: Text(
            section == OrdersSection.running
                ? Strings.ordersCurrentEmpty
                : Strings.ordersPastEmpty,
            style: AppTextStyles.body(color: c.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      OrderListLoaded(:final orders, :final loadMore) => SliverList.separated(
        // One extra row for the load-more footer.
        itemCount: orders.length + 1,
        separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md.h),
        itemBuilder: (BuildContext context, int i) => i < orders.length
            ? switch (section) {
                OrdersSection.running => _RunningOrderCard(orders[i]),
                OrdersSection.past => _PastOrderCard(orders[i]),
              }
            : LoadMoreFooter(
                status: loadMore,
                onRetry: () => context.read<OrdersCubit>().loadMoreOf(section),
              ),
      ),
      OrderListError(:final failure) => SliverToBoxAdapter(
        child: ErrorText(
          message: failure.userMessage,
          onRetry: () => context.read<OrdersCubit>().load(),
        ),
      ),
      OrderListLoading() => SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xl.h),
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
    };
  }
}

class _RunningOrderCard extends StatelessWidget {
  final OrderListEntry order;

  const _RunningOrderCard(this.order);

  @override
  Widget build(BuildContext context) {
    return CurrentOrderCard(
      storeName: order.storeName ?? Strings.orderTrackingStoreLabel,
      timeAndOrderId: order.dateAndNumber(
        DateTime.now(),
        Localizations.localeOf(context).languageCode,
      ),
      statusLabel: order.status.label,
      itemsDescription: order.itemsLabel,
      priceLabel: order.amountLabel,
      icon: order.icon,
      onTrack: () => context.push(AppRoutes.orderTrackingPath(order.id)),
    );
  }
}

class _PastOrderCard extends StatelessWidget {
  final OrderListEntry order;

  const _PastOrderCard(this.order);

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final (Color badgeBackground, Color badgeColor) = order.status.badgeColors(
      c,
    );
    final (Color iconBackground, Color iconColor) = order.iconColors(c);
    return BlocSelector<ReorderCubit, ReorderState, bool>(
      selector: (ReorderState state) => switch (state) {
        ReorderInProgress(:final orderId) ||
        ReorderAwaitingConfirmation(:final orderId) => orderId == order.id,
        _ => false,
      },
      builder: (BuildContext context, bool reordering) => PastOrderCard(
        storeName: order.storeName ?? Strings.orderTrackingStoreLabel,
        dateAndOrderId: order.dateAndNumber(
          DateTime.now(),
          Localizations.localeOf(context).languageCode,
        ),
        itemsDescription: order.itemsLabel,
        priceLabel: order.amountLabel,
        statusLabel: order.status.label,
        statusBackground: badgeBackground,
        statusColor: badgeColor,
        icon: order.icon,
        iconBackground: iconBackground,
        iconColor: iconColor,
        reordering: reordering,
        onReorder: () => context.read<ReorderCubit>().reorder(order),
      ),
    );
  }
}

/// Carries a reorder through: asks before emptying another store's cart,
/// opens the cart once the items are in, and reports what went wrong.
/// Never rebuilds [child].
class _ReorderListener extends StatelessWidget {
  final Widget child;

  const _ReorderListener({required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReorderCubit, ReorderState>(
      listener: (BuildContext context, ReorderState state) async {
        switch (state) {
          case ReorderAwaitingConfirmation():
            final ReorderCubit cubit = context.read<ReorderCubit>();
            final bool replace = await confirmCartReplace(
              context,
              body: Strings.ordersReorderOtherStoreBody,
            );
            if (replace) {
              await cubit.confirmReplace();
            } else {
              cubit.cancelReplace();
            }
          case ReorderSucceeded(:final skipped):
            if (skipped > 0) {
              showAppSnackBar(
                context: context,
                message: Strings.ordersReorderPartial(skipped),
                type: ToastType.info,
              );
            }
            // A fresh CartCubit there loads the cart as the server has it.
            context.push(AppRoutes.cart);
          case ReorderUnavailable():
            showAppSnackBar(
              context: context,
              message: Strings.ordersReorderUnavailable,
              type: ToastType.info,
            );
          case ReorderFailed(:final failure):
            showAppSnackBar(
              context: context,
              message: failure.userMessage,
              type: ToastType.error,
            );
          case ReorderIdle() || ReorderInProgress():
            break;
        }
      },
      child: child,
    );
  }
}
