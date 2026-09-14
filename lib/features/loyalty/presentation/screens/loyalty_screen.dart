import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../../../../core/widgets/tinted_note.dart';
import '../widgets/loyalty_free_delivery_card.dart';
import '../widgets/loyalty_linear_progress.dart';
import '../widgets/loyalty_progress_card.dart';
import '../widgets/loyalty_recent_order_tile.dart';

/// Placeholder progress — swap for the resolved order count once the
/// loyalty data layer exists.
const int _placeholderCompletedOrders = 7;
const int _placeholderTargetOrders = 10;
const int _placeholderRecentOrderCount = 3;

/// SSM Points / loyalty screen — pushed as a top-level route outside
/// [MainScaffold]'s shell, same treatment as Cart/Order Confirmation/Order
/// Tracking, so no bottom navigation bar here.
class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final double progress =
        _placeholderCompletedOrders / _placeholderTargetOrders;
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
              LoyaltyProgressCard(
                completed: _placeholderCompletedOrders,
                target: _placeholderTargetOrders,
              ),
              SizedBox(height: AppSpacing.lg.h),
              LoyaltyLinearProgress(progress: progress),
              SizedBox(height: AppSpacing.lg.h),
              TintedNote(
                text: Strings.loyaltyNoSubscriptionNote,
                backgroundColor: c.secondaryLight,
                textColor: c.secondaryDark,
              ),
              SizedBox(height: AppSpacing.md.h),
              const LoyaltyFreeDeliveryCard(),
              SizedBox(height: AppSpacing.lg.h),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      Strings.loyaltyRecentOrdersTitle,
                      style: AppTextStyles.title(color: c.textPrimary),
                    ),
                  ),
                  // TODO: open the full order-history screen once it exists.
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      Strings.loyaltyViewHistoryLink,
                      style: AppTextStyles.titleSmall(color: c.secondary),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md.h),
              Row(
                children: <Widget>[
                  for (int i = 0; i < _placeholderRecentOrderCount; i++) ...<Widget>[
                    if (i > 0) SizedBox(width: AppSpacing.sm.w),
                    const Expanded(child: LoyaltyRecentOrderTile()),
                  ],
                ],
              ),
              SizedBox(height: AppSpacing.lg.h),
              AppButton(
                btnText: Strings.loyaltyOrderNowButton,
                // TODO: navigate to the ordering flow's entry point once
                // there's one canonical place to send this to.
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
