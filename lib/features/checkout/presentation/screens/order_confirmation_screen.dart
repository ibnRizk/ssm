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
import '../../../../core/widgets/simple_app_bar.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../widgets/order_confirmation_address_card.dart';
import '../widgets/order_confirmation_delivery_fee_section.dart';
import '../widgets/order_confirmation_payment_card.dart';
import '../widgets/order_confirmation_summary_card.dart';

/// Placeholder saved address — swap for the resolved address once that flow
/// exists.
const String _placeholderNeighborhood = 'حي الملك فهد';
const String _placeholderStreetDetails = 'شارع الأمير سلطان · تربة';

/// Placeholder area/fee tiers, in reading order (right-to-left) — matches
/// the "تربة / العلاوة / الحايرة / الحشرج" tiers referenced elsewhere
/// (Cart, Pharmacy Order) for the same delivery zone.
const List<DeliveryArea> _placeholderAreas = <DeliveryArea>[
  DeliveryArea(name: 'تربة', fee: 10),
  DeliveryArea(name: 'العلاوة', fee: 15),
  DeliveryArea(name: 'الحايرة', fee: 20),
  DeliveryArea(name: 'الحشرج', fee: 25),
];

/// Order confirmation / checkout screen — pushed as a top-level route
/// outside [MainScaffold]'s shell, same treatment as Cart and Store Details,
/// so no bottom navigation bar here even though the design mock included one.
///
/// [CartCubit] is handed in via the route (the same instance Cart was
/// using — see `AppRoutes.orderConfirmation`), so the products-value row
/// stays in sync with the cart. Which delivery area is picked, though, is
/// local UI state owned right here: it only feeds this screen's own total,
/// so lifting it into the cart cubit (or further, a new cubit) would be
/// state management for state nothing outside this screen needs.
class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({super.key});

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  int _selectedAreaIndex = 0;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final int deliveryFee = _placeholderAreas[_selectedAreaIndex].fee;
    return Scaffold(
      backgroundColor: c.background,
      appBar: SimpleAppBar(
        title: Strings.orderConfirmationTitle,
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        child: BlocBuilder<CartCubit, CartState>(
          builder: (BuildContext context, CartState state) {
            final double subtotal = state is CartLoaded
                ? state.cart.subtotal
                : 0;
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
                  Text(
                    Strings.orderConfirmationAddressSectionTitle,
                    style: AppTextStyles.body(color: c.textSecondary),
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  const OrderConfirmationAddressCard(
                    neighborhood: _placeholderNeighborhood,
                    streetDetails: _placeholderStreetDetails,
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  Text(
                    Strings.orderConfirmationDeliveryFeeSectionTitle,
                    style: AppTextStyles.body(color: c.textSecondary),
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  OrderConfirmationDeliveryFeeSection(
                    areas: _placeholderAreas,
                    selectedIndex: _selectedAreaIndex,
                    onSelected: (int index) =>
                        setState(() => _selectedAreaIndex = index),
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  Text(
                    Strings.orderConfirmationPaymentSectionTitle,
                    style: AppTextStyles.body(color: c.textSecondary),
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  const OrderConfirmationPaymentCard(),
                  SizedBox(height: AppSpacing.lg.h),
                  Text(
                    Strings.orderConfirmationSummarySectionTitle,
                    style: AppTextStyles.body(color: c.textSecondary),
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  OrderConfirmationSummaryCard(
                    subtotal: subtotal,
                    deliveryFee: deliveryFee.toDouble(),
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  AppButton(
                    btnText: Strings.orderConfirmationConfirmButton,
                    // TODO: actually submit the order once the ordering API
                    // exists — this just proves the flow through to tracking.
                    onPressed: () => context.push(AppRoutes.orderTracking),
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
