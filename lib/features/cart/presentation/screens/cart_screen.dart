import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_text.dart';
import '../../../../core/widgets/no_data_found.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../../domain/entities/cart.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_notice_listener.dart';
import '../widgets/cart_order_summary.dart';

/// The cart screen — pushed as a top-level route outside [MainScaffold]'s
/// shell, same treatment as [RestaurantDetailsScreen], so the bottom
/// navigation bar never shows here.
///
/// [CartCubit] is handed in via the route (the same instance the store
/// screen was using — see `AppRoutes.cart`), so changes here show up in the
/// store's cart bar on the way back.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: SimpleAppBar(
        title: Strings.cartTitle,
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        child: CartNoticeListener(
          child: BlocBuilder<CartCubit, CartState>(
            builder: (BuildContext context, CartState state) => switch (state) {
              CartLoaded(:final cart) when cart.isEmpty => NoDataFound(
                text: Strings.cartEmptyMessage,
              ),
              CartLoaded(:final cart, :final busyLineIds) => _CartBody(
                cart: cart,
                busyLineIds: busyLineIds,
              ),
              CartError(:final failure) => ErrorText(
                message: failure.userMessage,
                onRetry: () => context.read<CartCubit>().load(),
              ),
              CartInitial() ||
              CartLoading() => const Center(child: CircularProgressIndicator()),
            },
          ),
        ),
      ),
    );
  }
}

class _CartBody extends StatelessWidget {
  final Cart cart;
  final Set<int> busyLineIds;

  const _CartBody({required this.cart, required this.busyLineIds});

  @override
  Widget build(BuildContext context) {
    final CartCubit cubit = context.read<CartCubit>();
    return RefreshIndicator(
      onRefresh: cubit.load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screen.w,
          AppSpacing.md.h,
          AppSpacing.screen.w,
          AppSpacing.xxl.h,
        ),
        children: <Widget>[
          for (final CartLine line in cart.lines) ...<Widget>[
            CartItemCard(
              key: ValueKey<int>(line.id),
              line: line,
              busy: busyLineIds.contains(line.id),
              onIncrement: () => cubit.increment(line),
              onDecrement: () => cubit.decrement(line),
              onRemove: () => cubit.remove(line),
            ),
            SizedBox(height: AppSpacing.md.h),
          ],
          SizedBox(height: AppSpacing.md.h),
          CartOrderSummary(subtotal: cart.subtotal),
          SizedBox(height: AppSpacing.lg.h),
          AppButton(
            btnText: Strings.cartContinueButton,
            // Checkout reads the cart through the same cubit.
            onPressed: busyLineIds.isEmpty
                ? () => context.push(AppRoutes.orderConfirmation, extra: cubit)
                : null,
          ),
        ],
      ),
    );
  }
}
