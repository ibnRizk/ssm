import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/tinted_note.dart';
import '../../domain/entities/loyalty_history.dart';
import '../../domain/entities/loyalty_progress.dart';
import '../cubit/loyalty_cubit.dart';
import 'loyalty_free_delivery_card.dart';
import 'loyalty_linear_progress.dart';
import 'loyalty_progress_card.dart';
import 'loyalty_recent_order_tile.dart';

/// The loaded Loyalty screen body, pull-to-refresh enabled.
class LoyaltyContent extends StatelessWidget {
  final LoyaltyProgress progress;

  /// Null when history couldn't be fetched — the recent-orders row is hidden.
  final LoyaltyHistory? history;

  const LoyaltyContent({super.key, required this.progress, this.history});

  /// The row fits three tiles side by side.
  static const int _maxRecentTiles = 3;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final int recentTiles = min(history?.recentCount ?? 0, _maxRecentTiles);
    return RefreshIndicator(
      onRefresh: () => context.read<LoyaltyCubit>().load(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screen.w,
          AppSpacing.md.h,
          AppSpacing.screen.w,
          AppSpacing.xxl.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            LoyaltyProgressCard(progress: progress),
            SizedBox(height: AppSpacing.lg.h),
            LoyaltyLinearProgress(progress: progress.percent / 100),
            SizedBox(height: AppSpacing.lg.h),
            TintedNote(
              text: Strings.loyaltyNoSubscriptionNote(
                progress.eligibleOrdersRequired,
              ),
              backgroundColor: c.secondaryLight,
              textColor: c.secondaryDark,
            ),
            SizedBox(height: AppSpacing.md.h),
            LoyaltyFreeDeliveryCard(
              availableFreeDeliveries: progress.availableFreeDeliveries,
              eligibleOrdersRequired: progress.eligibleOrdersRequired,
            ),
            if (recentTiles > 0) ...<Widget>[
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
                  for (int i = 0; i < recentTiles; i++) ...<Widget>[
                    if (i > 0) SizedBox(width: AppSpacing.sm.w),
                    const Expanded(child: LoyaltyRecentOrderTile()),
                  ],
                  // Keep tiles the same width when there are fewer than 3.
                  for (
                    int i = recentTiles;
                    i < _maxRecentTiles;
                    i++
                  ) ...<Widget>[
                    SizedBox(width: AppSpacing.sm.w),
                    const Expanded(child: SizedBox.shrink()),
                  ],
                ],
              ),
            ],
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
    );
  }
}
