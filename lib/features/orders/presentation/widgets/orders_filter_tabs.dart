import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// Which filter is active is pure UI state — no business logic — so it's
/// `setState`, scoped to just this row, same treatment as
/// [RestaurantCategoryTabs].
///
/// TODO: actually filter the current/past sections once there's more than
/// one mock order per section to filter.
class OrdersFilterTabs extends StatefulWidget {
  const OrdersFilterTabs({super.key});

  @override
  State<OrdersFilterTabs> createState() => _OrdersFilterTabsState();
}

class _OrdersFilterTabsState extends State<OrdersFilterTabs> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final List<String> labels = <String>[
      Strings.ordersFilterAll,
      Strings.ordersFilterCurrent,
      Strings.ordersFilterPast,
    ];
    return Row(
      children: <Widget>[
        for (int i = 0; i < labels.length; i++) ...<Widget>[
          if (i > 0) SizedBox(width: AppSpacing.lg.w),
          GestureDetector(
            onTap: () => setState(() => _selectedIndex = i),
            child: i == _selectedIndex
                ? Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md.w,
                      vertical: AppSpacing.xs.h,
                    ),
                    decoration: BoxDecoration(
                      color: c.primary,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      labels[i],
                      style: AppTextStyles.titleSmall(color: Colors.white),
                    ),
                  )
                : Text(
                    labels[i],
                    style: AppTextStyles.body(color: c.textHint),
                  ),
          ),
        ],
      ],
    );
  }
}
