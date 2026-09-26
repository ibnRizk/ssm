import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_dimens.dart';
import '../widgets/account_footer.dart';
import '../widgets/account_header_bar.dart';
import '../widgets/account_logout_button.dart';
import '../widgets/account_profile_card.dart';
import '../widgets/account_settings_section.dart';

/// Placeholder profile — swap for real data from the auth/profile feature's
/// data layer once it exists.
const String _placeholderName = 'عبدالعزيز محمد';
const String _placeholderAvatarLetter = 'ع';
const String _placeholderPhone = '0554123456';
const int _placeholderMemberSinceYear = 2026;

/// Account tab body. The bottom navigation bar and its Scaffold live in
/// [MainScaffold] — this widget is only the scrollable content for that tab.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screen.w,
          AppSpacing.lg.h,
          AppSpacing.screen.w,
          AppSpacing.xxl.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const AccountHeaderBar(),
            SizedBox(height: AppSpacing.lg.h),
            AccountProfileCard(
              name: _placeholderName,
              avatarLetter: _placeholderAvatarLetter,
              phone: _placeholderPhone,
              memberSinceYear: _placeholderMemberSinceYear,
              // TODO: open the "edit my info" screen once it exists.
              onEdit: () {},
            ),
            SizedBox(height: AppSpacing.xl.h),
            const AccountSettingsSection(),
            SizedBox(height: AppSpacing.lg.h),
            const AccountLogoutButton(),
            SizedBox(height: AppSpacing.xl.h),
            const AccountFooter(),
          ],
        ),
      ),
    );
  }
}
