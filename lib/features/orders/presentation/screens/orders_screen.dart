import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../widgets/current_order_card.dart';
import '../widgets/orders_filter_tabs.dart';
import '../widgets/orders_header.dart';
import '../widgets/past_order_card.dart';

class _PastOrderListItem {
  final String storeName;
  final String dateAndOrderId;
  final String itemsDescription;
  final int price;
  final IconData icon;
  final Color Function(AppColors) iconBackground;
  final Color Function(AppColors) iconColor;

  const _PastOrderListItem({
    required this.storeName,
    required this.dateAndOrderId,
    required this.itemsDescription,
    required this.price,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
  });
}

/// Placeholder order history — swap for real data from the orders feature's
/// data layer once it exists.
const int _placeholderTotalOrders = 12;
const String _placeholderCurrentStoreName = 'مطاعم مذاق';
const String _placeholderCurrentOrderNumber = 'SSM-1048';
const String _placeholderCurrentTimeAndOrderId =
    'اليوم، ٨:٢٤ م · #$_placeholderCurrentOrderNumber';
const String _placeholderCurrentItemsDescription = 'وجبة برجر 2 × SSM + بطاطس';
const int _placeholderCurrentPrice = 71;

const List<_PastOrderListItem> _placeholderPastOrders = <_PastOrderListItem>[
  _PastOrderListItem(
    storeName: 'كافيه وقت',
    dateAndOrderId: 'أمس، ٦:١٢ م · #SSM-1039',
    itemsDescription: 'لاتيه مثلج + كرواسون',
    price: 24,
    icon: Icons.coffee,
    iconBackground: _peach,
    iconColor: _peachIcon,
  ),
  _PastOrderListItem(
    storeName: 'سوبرماركت الوفرة',
    dateAndOrderId: '18 أغسطس · #SSM-1028',
    itemsDescription: 'مشتريات منزلية · 8 أصناف',
    price: 112,
    icon: Icons.shopping_cart_outlined,
    iconBackground: _blue,
    iconColor: _blueIcon,
  ),
];

Color _peach(AppColors c) => c.secondaryLight;
Color _peachIcon(AppColors c) => c.secondary;
Color _blue(AppColors c) => c.info.withValues(alpha: 0.12);
Color _blueIcon(AppColors c) => c.info;

/// Orders tab body. The bottom navigation bar and its Scaffold live in
/// [MainScaffold] — this widget is only the scrollable content for that tab.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
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
            const OrdersHeader(totalOrders: _placeholderTotalOrders),
            SizedBox(height: AppSpacing.lg.h),
            const OrdersFilterTabs(),
            SizedBox(height: AppSpacing.sm.h),
            Divider(color: c.border, height: 1),
            SizedBox(height: AppSpacing.lg.h),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    Strings.ordersCurrentSectionTitle,
                    style: AppTextStyles.title(color: c.textPrimary),
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push(
                    AppRoutes.orderTracking,
                    extra: <String, String>{
                      'storeName': _placeholderCurrentStoreName,
                      'orderNumber': _placeholderCurrentOrderNumber,
                    },
                  ),
                  child: Text(
                    Strings.ordersViewTrackingLink,
                    style: AppTextStyles.titleSmall(color: c.secondary),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md.h),
            CurrentOrderCard(
              storeName: _placeholderCurrentStoreName,
              timeAndOrderId: _placeholderCurrentTimeAndOrderId,
              statusLabel: Strings.ordersStatusPreparing,
              itemsDescription: _placeholderCurrentItemsDescription,
              price: _placeholderCurrentPrice,
              icon: Icons.lunch_dining,
              onTrack: () => context.push(
                AppRoutes.orderTracking,
                extra: <String, String>{
                  'storeName': _placeholderCurrentStoreName,
                  'orderNumber': _placeholderCurrentOrderNumber,
                },
              ),
            ),
            SizedBox(height: AppSpacing.xl.h),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    Strings.ordersPastSectionTitle,
                    style: AppTextStyles.title(color: c.textPrimary),
                  ),
                ),
                Text(
                  Strings.ordersNewestFirstLabel,
                  style: AppTextStyles.caption(color: c.secondary),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md.h),
            for (int i = 0; i < _placeholderPastOrders.length; i++) ...<Widget>[
              if (i > 0) SizedBox(height: AppSpacing.md.h),
              PastOrderCard(
                storeName: _placeholderPastOrders[i].storeName,
                dateAndOrderId: _placeholderPastOrders[i].dateAndOrderId,
                itemsDescription: _placeholderPastOrders[i].itemsDescription,
                price: _placeholderPastOrders[i].price,
                icon: _placeholderPastOrders[i].icon,
                iconBackground: _placeholderPastOrders[i].iconBackground(c),
                iconColor: _placeholderPastOrders[i].iconColor(c),
                // TODO: re-add the past order's items to the cart once a
                // "reorder" flow exists.
                onReorder: () {},
              ),
            ],
          ],
        ),
      ),
    );
  }
}
