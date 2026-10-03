import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_dimens.dart';
import '../cubit/profile_cubit.dart';
import '../widgets/account_delete_button.dart';
import '../widgets/account_footer.dart';
import '../widgets/account_header_bar.dart';
import '../widgets/account_logout_button.dart';
import '../widgets/account_profile_section.dart';
import '../widgets/account_settings_section.dart';

/// Account tab body. The bottom navigation bar and its Scaffold live in
/// [MainScaffold] — this widget is only the scrollable content for that tab.
///
/// Expects a [ProfileCubit] (profile card + loyalty row), an `AuthCubit`
/// (logout) and a `DeleteAccountCubit` above it — all provided at the
/// profile route.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () => context.read<ProfileCubit>().load(),
        child: SingleChildScrollView(
          // Pull-to-refresh must work even when the content is shorter than
          // the viewport.
          physics: const AlwaysScrollableScrollPhysics(),
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
              const AccountProfileSection(),
              SizedBox(height: AppSpacing.xl.h),
              const AccountSettingsSection(),
              SizedBox(height: AppSpacing.lg.h),
              const AccountLogoutButton(),
              SizedBox(height: AppSpacing.sm.h),
              const AccountDeleteButton(),
              SizedBox(height: AppSpacing.lg.h),
              const AccountFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
