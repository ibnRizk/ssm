import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/no_data_found.dart';
import '../../domain/entities/address.dart';
import '../cubit/addresses_cubit.dart';
import 'address_card.dart';

/// The saved addresses, pull-to-refresh enabled, or an empty state.
class AddressesList extends StatelessWidget {
  final List<Address> addresses;
  final Set<int> deletingIds;

  const AddressesList({
    super.key,
    required this.addresses,
    required this.deletingIds,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<AddressesCubit>().load(),
      child: addresses.isEmpty
          // Scrollable so pull-to-refresh still works on the empty state.
          ? LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) =>
                  SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: constraints.maxHeight,
                      child: NoDataFound(text: Strings.addressesEmpty),
                    ),
                  ),
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screen.w,
                AppSpacing.md.h,
                AppSpacing.screen.w,
                AppSpacing.md.h,
              ),
              itemCount: addresses.length,
              separatorBuilder: (_, _) => SizedBox(height: AppSpacing.sm.h),
              itemBuilder: (BuildContext context, int index) {
                final Address address = addresses[index];
                return AddressCard(
                  key: ValueKey<int>(address.id),
                  address: address,
                  isDeleting: deletingIds.contains(address.id),
                );
              },
            ),
    );
  }
}
