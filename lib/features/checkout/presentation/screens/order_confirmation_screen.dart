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
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/error_text.dart';
import '../../../../core/widgets/option_picker_sheet.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../../../addresses/domain/entities/address.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../domain/entities/order_request.dart';
import '../cubit/checkout_cubit.dart';
import '../cubit/checkout_state.dart';
import '../utils/checkout_messages.dart';
import '../widgets/order_confirmation_address_card.dart';
import '../widgets/order_confirmation_payment_card.dart';
import '../widgets/order_confirmation_summary_card.dart';

/// Checkout — pushed as a top-level route outside [MainScaffold]'s shell,
/// same treatment as Cart and Store Details, so no bottom navigation bar.
///
/// Reads the [CartCubit] the Cart screen handed over (see
/// `AppRoutes.orderConfirmation`) and its own [CheckoutCubit] for the
/// address and the placing. Once the order is placed, the flow restarts
/// from Home with tracking on top, so Back never returns to a spent cart.
class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: SimpleAppBar(
        title: Strings.orderConfirmationTitle,
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        child: _CheckoutFeedbackListener(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screen.w,
              AppSpacing.md.h,
              AppSpacing.screen.w,
              AppSpacing.xxl.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _SectionTitle(Strings.orderConfirmationAddressSectionTitle),
                const _AddressSection(),
                SizedBox(height: AppSpacing.lg.h),
                _SectionTitle(Strings.orderConfirmationPaymentSectionTitle),
                const OrderConfirmationPaymentCard(),
                SizedBox(height: AppSpacing.lg.h),
                _SectionTitle(Strings.orderConfirmationSummarySectionTitle),
                BlocSelector<CartCubit, CartState, double>(
                  selector: (CartState state) =>
                      state is CartLoaded ? state.cart.subtotal : 0,
                  builder: (_, double subtotal) =>
                      OrderConfirmationSummaryCard(subtotal: subtotal),
                ),
                SizedBox(height: AppSpacing.lg.h),
                const _PlaceOrderButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
      child: Text(
        text,
        style: AppTextStyles.body(color: context.colors.textSecondary),
      ),
    );
  }
}

class _AddressSection extends StatelessWidget {
  const _AddressSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutCubit, CheckoutState>(
      buildWhen: (CheckoutState previous, CheckoutState current) =>
          previous.addresses != current.addresses ||
          previous.addressId != current.addressId,
      builder: (BuildContext context, CheckoutState state) =>
          switch (state.addresses) {
            CheckoutAddressesLoading() => Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
              child: const Center(child: CircularProgressIndicator()),
            ),
            CheckoutAddressesError(:final failure) => ErrorText(
              message: failure.userMessage,
              onRetry: () => context.read<CheckoutCubit>().loadAddresses(),
            ),
            CheckoutAddressesLoaded(:final List<Address> items) =>
              switch (state.selectedAddress) {
                null => OrderConfirmationAddressCard(
                  title: Strings.checkoutNoAddresses,
                  actionLabel: Strings.checkoutAddAddress,
                  onAction: () => _addAddress(context),
                ),
                final Address address => OrderConfirmationAddressCard(
                  title: address.address,
                  subtitle:
                      '${address.contactPersonName} · '
                      '${address.contactPersonNumber}',
                  actionLabel: Strings.orderConfirmationChangeButton,
                  onAction: () => _pickAddress(context, items, address.id),
                ),
              },
          },
    );
  }

  Future<void> _pickAddress(
    BuildContext context,
    List<Address> addresses,
    int selectedId,
  ) async {
    final CheckoutCubit cubit = context.read<CheckoutCubit>();
    final int? picked = await OptionPickerSheet.show(
      context,
      title: Strings.orderConfirmationAddressSectionTitle,
      selectedId: selectedId,
      emptyText: Strings.checkoutNoAddresses,
      options: <PickerOption>[
        for (final Address address in addresses)
          PickerOption(
            id: address.id,
            title: address.address,
            subtitle: address.contactPersonName,
          ),
      ],
    );
    if (picked != null) cubit.selectAddress(picked);
  }

  /// Add Address pops `true` on save — then the new address is offered.
  Future<void> _addAddress(BuildContext context) async {
    final CheckoutCubit cubit = context.read<CheckoutCubit>();
    final bool? added = await context.push<bool>(AppRoutes.addAddress);
    if (added ?? false) await cubit.loadAddresses();
  }
}

class _PlaceOrderButton extends StatelessWidget {
  const _PlaceOrderButton();

  @override
  Widget build(BuildContext context) {
    final bool placing = context.select<CheckoutCubit, bool>(
      (CheckoutCubit cubit) => cubit.state.placing,
    );
    // Only a settled cart can be ordered: none still loading, no line
    // mid-change.
    final bool cartReady = context.select<CartCubit, bool>(
      (CartCubit cubit) => switch (cubit.state) {
        CartLoaded(:final busyLineIds, :final addingItemIds) =>
          busyLineIds.isEmpty && addingItemIds.isEmpty,
        _ => false,
      },
    );
    return AppButton(
      btnText: Strings.orderConfirmationConfirmButton,
      isLoading: placing,
      onPressed: cartReady
          ? () {
              final CartState cart = context.read<CartCubit>().state;
              if (cart is CartLoaded) {
                context.read<CheckoutCubit>().placeOrder(cart.cart);
              }
            }
          : null,
    );
  }
}

/// Snackbars for notices; on a placed order, Home with tracking on top.
class _CheckoutFeedbackListener extends StatelessWidget {
  final Widget child;

  const _CheckoutFeedbackListener({required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CheckoutCubit, CheckoutState>(
          listenWhen: (CheckoutState previous, CheckoutState current) =>
              current.notice != null && previous.notice != current.notice,
          listener: (BuildContext context, CheckoutState state) =>
              showAppSnackBar(
                context: context,
                message: state.notice!.message,
                type: ToastType.error,
              ),
        ),
        BlocListener<CheckoutCubit, CheckoutState>(
          listenWhen: (CheckoutState previous, CheckoutState current) =>
              previous.placedOrder == null && current.placedOrder != null,
          listener: (BuildContext context, CheckoutState state) {
            final PlacedOrder order = state.placedOrder!;
            showAppSnackBar(
              context: context,
              message: Strings.checkoutOrderPlaced,
              type: ToastType.success,
            );
            GoRouter.of(context)
              ..go(AppRoutes.home)
              ..push(AppRoutes.orderTrackingPath(order.id));
          },
        ),
      ],
      child: child,
    );
  }
}
