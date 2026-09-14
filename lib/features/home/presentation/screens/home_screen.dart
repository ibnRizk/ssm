import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_dimens.dart';
import '../widgets/home_categories_section.dart';
import '../widgets/home_header.dart';
import '../widgets/home_offers_section.dart';
import '../widgets/home_search_field.dart';
import '../widgets/home_subscription_banner.dart';

/// Home tab body. The bottom navigation bar and its Scaffold live in
/// [MainScaffold] — this widget is only the scrollable content for that tab.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
            const HomeHeader(),
            SizedBox(height: AppSpacing.lg.h),
            const HomeSearchField(),
            SizedBox(height: AppSpacing.lg.h),
            const HomeSubscriptionBanner(),
            SizedBox(height: AppSpacing.xl.h),
            const HomeCategoriesSection(),
            SizedBox(height: AppSpacing.xl.h),
            const HomeOffersSection(),
          ],
        ),
      ),
    );
  }
}
