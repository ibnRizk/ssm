import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';

/// Placeholder landing screen. It exists to prove routing, theming, i18n and
/// the shared widgets are wired — delete it when you build the real one.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              style: AppTextStyles.h2(color: context.colors.textPrimary),
            ),
            SizedBox(height: 8.h),
            Text(
              'Replace this screen with your first feature.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body(color: context.colors.textSecondary),
            ),
            SizedBox(height: 32.h),
            AppButton(
              btnText: Strings.language,
              onPressed: () => context.pushNamed(AppRoutes.changeLanguageName),
            ),
          ],
        ),
      ),
    );
  }
}
