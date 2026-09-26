import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/utils/enum_extensions.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/show_modal_bottom_sheet.dart';
import '../../../loyalty/domain/entities/loyalty_progress.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import 'account_settings_tile.dart';
import 'language_selector_sheet.dart';

/// "إعدادات الحساب" section: title + a white card listing the account's
/// settings rows, separated by hairline dividers.
class AccountSettingsSection extends StatelessWidget {
  const AccountSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    final List<Widget> tiles = <Widget>[
      AccountSettingsTile(
        icon: Icons.location_on_outlined,
        title: Strings.accountAddressesTitle,
        // Placeholder until the addresses list is integrated.
        subtitle: Strings.accountAddressesSubtitle,
        onTap: () => context.push(AppRoutes.addresses),
      ),
      const _LoyaltyTile(),
      AccountSettingsTile(
        icon: Icons.help_outline,
        title: Strings.accountHelpTitle,
        subtitle: Strings.accountHelpSubtitle,
        onTap: () => context.push(AppRoutes.helpSupport),
      ),
      AccountSettingsTile(
        icon: Icons.dark_mode_outlined,
        title: Strings.accountAppearanceTitle,
        subtitle: Strings.accountAppearanceSubtitle,
        trailing: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
              activeTrackColor: c.secondary,
            );
          },
        ),
        onTap: () => context.read<ThemeCubit>().toggleTheme(),
      ),
      AccountSettingsTile(
        icon: Icons.language,
        title: Strings.language,
        subtitle: LanguageCodeExtension.fromString(
          Localizations.localeOf(context).languageCode,
        ).displayName,
        onTap: () => showAppModalBottomSheet(
          context: context,
          child: const LanguageSelectorSheet(),
        ),
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
          decoration: AppDecorations.card(c),
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

/// Bound to `GET /customer/loyalty` through [ProfileCubit]. Rebuilds only
/// when the progress itself changes; shows a neutral subtitle and no badge
/// while it's loading or if it couldn't be fetched.
class _LoyaltyTile extends StatelessWidget {
  const _LoyaltyTile();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return BlocSelector<ProfileCubit, ProfileState, LoyaltyProgress?>(
      selector: (ProfileState state) =>
          state is ProfileLoaded ? state.loyalty : null,
      builder: (BuildContext context, LoyaltyProgress? loyalty) =>
          AccountSettingsTile(
            icon: Icons.card_giftcard_outlined,
            title: Strings.accountLoyaltyTitle,
            subtitle: loyalty == null
                ? Strings.accountLoyaltySubtitleFallback
                : Strings.accountLoyaltySubtitle(
                    loyalty.currentProgress,
                    loyalty.eligibleOrdersRequired,
                  ),
            badge: loyalty == null
                ? null
                : Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: c.successLight,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      '${loyalty.percent}%',
                      style: AppTextStyles.label(color: c.success),
                    ),
                  ),
            onTap: () => context.push(AppRoutes.loyalty),
          ),
    );
  }
}
