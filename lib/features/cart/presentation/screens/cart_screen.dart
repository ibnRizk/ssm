import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/no_data_found.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../../../restaurants/presentation/cubit/store_cart_cubit.dart';
import '../../../restaurants/presentation/cubit/store_cart_state.dart';
import '../widgets/cart_delivery_area_banner.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_order_summary.dart';

/// Placeholder flat delivery fee — swap for the resolved zone's real quote
/// once the pricing feature exists.
const int _placeholderDeliveryFee = 10;

/// Placeholder area-fee breakdown shown under the summary.
const String _placeholderAreaFeeBreakdown =
    'العلاوة 15 ر.س · الحارة والقويعية 20 ر.س · الحرشف 25 ر.س';

/// The cart screen — pushed as a top-level route outside [MainScaffold]'s
/// shell, same treatment as [RestaurantDetailsScreen], so the bottom
/// navigation bar never shows here even though the design mock happened to
/// include one.
///
/// [StoreCartCubit] is handed in via the route (the same instance the store
/// screen was using — see `AppRoutes.cart`), not created here, so quantity
/// changes stay in sync with wherever else that cubit is read.
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
        child: BlocBuilder<StoreCartCubit, StoreCartState>(
          builder: (BuildContext context, StoreCartState state) {
            if (state.lineItems.isEmpty) {
              return NoDataFound(text: Strings.cartEmptyMessage);
            }
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screen.w,
                AppSpacing.md.h,
                AppSpacing.screen.w,
                AppSpacing.xxl.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const CartDeliveryAreaBanner(),
                  SizedBox(height: AppSpacing.lg.h),
                  for (int i = 0; i < state.lineItems.length; i++) ...<Widget>[
                    if (i > 0) SizedBox(height: AppSpacing.md.h),
                    CartItemCard(
                      name: state.lineItems[i].name,
                      subtitle: state.lineItems[i].subtitle,
                      quantity: state.lineItems[i].quantity,
                      onIncrement: () => context
                          .read<StoreCartCubit>()
                          .addProduct(
                            productId: state.lineItems[i].productId,
                            name: state.lineItems[i].name,
                            subtitle: state.lineItems[i].subtitle,
                            unitPrice: state.lineItems[i].unitPrice,
                          ),
                      onDecrement: () => context
                          .read<StoreCartCubit>()
                          .removeProduct(state.lineItems[i].productId),
                    ),
                  ],
                  SizedBox(height: AppSpacing.xl.h),
                  CartOrderSummary(
                    subtotal: state.subtotal,
                    deliveryFee: _placeholderDeliveryFee,
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  Text(
                    _placeholderAreaFeeBreakdown,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption(color: c.textSecondary),
                  ),
                  SizedBox(height: AppSpacing.md.h),
                  AppButton(
                    btnText: Strings.cartContinueButton,
                    onPressed: () => context.push(
                      AppRoutes.orderConfirmation,
                      extra: context.read<StoreCartCubit>(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
