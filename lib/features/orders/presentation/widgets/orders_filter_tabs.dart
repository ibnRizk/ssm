import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../cubit/orders_state.dart';

/// All / Current / Past. The selection lives in `OrdersCubit`, since it
/// decides which list the next page is fetched for.
class OrdersFilterTabs extends StatelessWidget {
  final OrdersFilter selected;
  final ValueChanged<OrdersFilter> onSelected;

  const OrdersFilterTabs({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static String _label(OrdersFilter filter) => switch (filter) {
    OrdersFilter.all => Strings.ordersFilterAll,
    OrdersFilter.current => Strings.ordersFilterCurrent,
    OrdersFilter.past => Strings.ordersFilterPast,
  };

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Row(
      children: <Widget>[
        for (final OrdersFilter filter in OrdersFilter.values) ...<Widget>[
          if (filter.index > 0) SizedBox(width: AppSpacing.lg.w),
          GestureDetector(
            onTap: () => onSelected(filter),
            child: filter == selected
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
                      _label(filter),
                      style: AppTextStyles.titleSmall(color: Colors.white),
                    ),
                  )
                : Text(
                    _label(filter),
                    style: AppTextStyles.body(color: c.textHint),
                  ),
          ),
        ],
      ],
    );
  }
}
