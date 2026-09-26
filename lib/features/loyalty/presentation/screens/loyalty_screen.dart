import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/error_text.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../cubit/loyalty_cubit.dart';
import '../cubit/loyalty_state.dart';
import '../widgets/loyalty_content.dart';

/// SSM Points / loyalty screen — pushed as a top-level route outside
/// [MainScaffold]'s shell, same treatment as Cart/Order Confirmation/Order
/// Tracking, so no bottom navigation bar here.
///
/// Expects a [LoyaltyCubit] above it — provided at the loyalty route.
class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: SimpleAppBar(
        title: Strings.loyaltyTitle,
        onBack: () => context.pop(),
        trailing: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm.w,
            vertical: 4.h,
          ),
          decoration: BoxDecoration(
            color: c.successLight,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            Strings.loyaltyAvailableBadge,
            style: AppTextStyles.label(color: c.success),
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<LoyaltyCubit, LoyaltyState>(
          builder: (BuildContext context, LoyaltyState state) =>
              switch (state) {
                LoyaltyLoaded(:final progress, :final history) =>
                  LoyaltyContent(progress: progress, history: history),
                LoyaltyError(:final failure) => ErrorText(
                  message: failure.userMessage,
                  onRetry: () => context.read<LoyaltyCubit>().load(),
                ),
                LoyaltyInitial() || LoyaltyLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
              },
        ),
      ),
    );
  }
}
