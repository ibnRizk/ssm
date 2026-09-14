import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import 'account_settings_tile.dart';

/// Placeholder progress, mirroring `LoyaltyScreen`'s own placeholder numbers
/// so the "70%" badge here matches what Loyalty shows once opened.
const int _placeholderLoyaltyCompleted = 7;
const int _placeholderLoyaltyTarget = 10;

/// "إعدادات الحساب" section: title + a white card listing the account's
/// settings rows, separated by hairline dividers.
class AccountSettingsSection extends StatelessWidget {
  const AccountSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final int loyaltyPercent =
        (_placeholderLoyaltyCompleted / _placeholderLoyaltyTarget * 100)
            .round();

    final List<Widget> tiles = <Widget>[
      AccountSettingsTile(
        icon: Icons.badge_outlined,
        title: Strings.accountMyInfoTitle,
        subtitle: Strings.accountMyInfoSubtitle,
        // TODO: open the "edit my info" screen once it exists.
        onTap: () {},
      ),
      AccountSettingsTile(
        icon: Icons.location_on_outlined,
        title: Strings.accountAddressesTitle,
        subtitle: Strings.accountAddressesSubtitle,
        // TODO: open the addresses list screen once it exists.
        onTap: () {},
      ),
      AccountSettingsTile(
        icon: Icons.card_membership_outlined,
        title: Strings.accountSubscriptionsTitle,
        subtitle: Strings.accountSubscriptionsSubtitleNone,
        onTap: () => context.go(AppRoutes.subscriptions),
      ),
      AccountSettingsTile(
        icon: Icons.card_giftcard_outlined,
        title: Strings.accountLoyaltyTitle,
        subtitle: Strings.accountLoyaltySubtitle(
          _placeholderLoyaltyCompleted,
          _placeholderLoyaltyTarget,
        ),
        badge: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xs.w,
            vertical: 3.h,
          ),
          decoration: BoxDecoration(
            color: c.successLight,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            '$loyaltyPercent%',
            style: AppTextStyles.label(color: c.success),
          ),
        ),
        onTap: () => context.push(AppRoutes.loyalty),
      ),
      AccountSettingsTile(
        icon: Icons.help_outline,
        title: Strings.accountHelpTitle,
        subtitle: Strings.accountHelpSubtitle,
        // TODO: open help & support once it exists.
        onTap: () {},
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          Strings.accountSettingsSectionTitle,
          style: AppTextStyles.title(color: c.textPrimary),
        ),
        SizedBox(height: AppSpacing.md.h),
        Container(
          decoration: AppDecorations.card(),
          child: Column(
            children: <Widget>[
              for (int i = 0; i < tiles.length; i++) ...<Widget>[
                tiles[i],
                if (i < tiles.length - 1)
                  Divider(
                    color: c.border,
                    height: 1,
                    indent: 68.w,
                    endIndent: AppSpacing.md.w,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
