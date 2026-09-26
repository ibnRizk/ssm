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
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/error_text.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../cubit/addresses_cubit.dart';
import '../cubit/addresses_state.dart';
import '../widgets/addresses_list.dart';

/// My Addresses — pushed from the Account tab, outside the bottom-nav
/// shell. Expects an [AddressesCubit] above it (provided at the route).
class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  Future<void> _openAddAddress(BuildContext context) async {
    // Captured before the await — the context may be gone by the time the
    // Add Address screen pops.
    final AddressesCubit cubit = context.read<AddressesCubit>();
    final bool? added = await context.push<bool>(AppRoutes.addAddress);
    if (added ?? false) await cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: SimpleAppBar(
        title: Strings.accountAddressesTitle,
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: BlocConsumer<AddressesCubit, AddressesState>(
                listenWhen: (AddressesState previous, AddressesState current) =>
                    current is AddressesLoaded && current.deleteFailure != null,
                listener: (BuildContext context, AddressesState state) =>
                    showAppSnackBar(
                      context: context,
                      message:
                          (state as AddressesLoaded).deleteFailure!.userMessage,
                      type: ToastType.error,
                    ),
                builder: (BuildContext context, AddressesState state) =>
                    switch (state) {
                      AddressesLoaded(:final addresses, :final deletingIds) =>
                        AddressesList(
                          addresses: addresses,
                          deletingIds: deletingIds,
                        ),
                      AddressesError(:final failure) => ErrorText(
                        message: failure.userMessage,
                        onRetry: () => context.read<AddressesCubit>().load(),
                      ),
                      AddressesInitial() || AddressesLoading() => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screen.w,
                AppSpacing.sm.h,
                AppSpacing.screen.w,
                AppSpacing.md.h,
              ),
              child: AppButton(
                btnText: Strings.addressesAddButton,
                onPressed: () => _openAddAddress(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
