import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/themes/theme_cubit.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';

/// Placeholder landing screen. It exists to prove routing, theming, i18n and
/// the shared widgets are wired — delete it when you build the real one.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Themes theme = context.watch<ThemeCubit>().state;

    return Scaffold(
      appBar: AppBar(title: Text(Strings.appName)),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Icon(
              Icons.rocket_launch_outlined,
              size: 64.r,
              color: context.colors.primary,
            ),
            SizedBox(height: 16.h),
            Text(
              'Base architecture is running.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Replace this screen with your first feature.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: context.colors.textSecondary,
              ),
            ),
            SizedBox(height: 32.h),
            AppButton(
              btnText: Strings.language,
              onPressed: () => context.pushNamed(AppRoutes.changeLanguageName),
            ),
            SizedBox(height: 12.h),
            OutlinedButton.icon(
              onPressed: () => context.read<ThemeCubit>().toggle(),
              icon: Icon(
                theme == Themes.dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
              label: Text(
                theme == Themes.dark ? Strings.lightMode : Strings.darkMode,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
