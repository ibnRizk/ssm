import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_dimens.dart';
import '../widgets/subscription_package_card.dart';
import '../widgets/subscriptions_area_card.dart';
import '../widgets/subscriptions_footer_note.dart';
import '../widgets/subscriptions_header.dart';

class _PackageListItem {
  final String title;
  final String subtitle;
  final int price;
  final bool featured;

  const _PackageListItem({
    required this.title,
    required this.subtitle,
    required this.price,
    this.featured = false,
  });
}

/// Placeholder plans — swap for real data from the subscriptions feature's
/// data layer once it exists.
const List<_PackageListItem> _placeholderPackages = <_PackageListItem>[
  _PackageListItem(
    title: 'باقة شهر',
    subtitle: '11 توصيلة · صلاحية 30 يوم',
    price: 100,
  ),
  _PackageListItem(
    title: 'باقة شهرين',
    subtitle: '22 توصيلة · صلاحية 60 يوم',
    price: 200,
  ),
  _PackageListItem(
    title: 'باقة 3 شهور',
    subtitle: '33 توصيلة · صلاحية 90 يوم',
    price: 300,
  ),
  _PackageListItem(
    title: 'الباقة الذهبية',
    subtitle: '44 توصيلة · صلاحية 120 يوم · الأوفر للعائلات',
    price: 400,
    featured: true,
  ),
];

/// Subscriptions tab body. The bottom navigation bar and its Scaffold live
/// in [MainScaffold] — this widget is only the scrollable content for that
/// tab.
class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

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
            const SubscriptionsHeader(),
            SizedBox(height: AppSpacing.lg.h),
            const SubscriptionsAreaCard(),
            SizedBox(height: AppSpacing.lg.h),
            for (int i = 0; i < _placeholderPackages.length; i++) ...<Widget>[
              if (i > 0) SizedBox(height: AppSpacing.md.h),
              SubscriptionPackageCard(
                title: _placeholderPackages[i].title,
                subtitle: _placeholderPackages[i].subtitle,
                price: _placeholderPackages[i].price,
                featured: _placeholderPackages[i].featured,
                // TODO: open the subscribe/checkout flow once it exists.
                onTap: () {},
              ),
            ],
            SizedBox(height: AppSpacing.lg.h),
            const SubscriptionsFooterNote(),
          ],
        ),
      ),
    );
  }
}
