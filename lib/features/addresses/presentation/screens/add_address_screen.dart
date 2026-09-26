import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../widgets/add_address_form.dart';

/// Pushed from My Addresses. Pops `true` once the address is saved so the
/// list refetches. Expects an `AddAddressCubit` above it (provided at the
/// route).
class AddAddressScreen extends StatelessWidget {
  const AddAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: SimpleAppBar(
        title: Strings.addAddressTitle,
        onBack: () => context.pop(),
      ),
      body: const SafeArea(child: AddAddressForm()),
    );
  }
}
