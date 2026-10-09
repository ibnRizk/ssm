import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// The two services Home switches between, in display order (start to end).
enum HomeService { orders, parcels }

/// A navy pill with an orange thumb that slides under the selected service.
///
/// Stateless — the selection is owned by the caller. The thumb is aligned
/// with [AlignmentDirectional], so under the RTL layout the first service
/// sits on the right without hardcoding a side.
class HomeServiceToggle extends StatelessWidget {
  final HomeService selected;
  final ValueChanged<HomeService> onChanged;

  const HomeServiceToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const Duration _duration = Duration(milliseconds: 250);

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final double inset = AppSpacing.xxs.r;
    return Container(
      height: AppSizes.buttonHeight.h,
      padding: EdgeInsets.all(inset),
      decoration: BoxDecoration(
        color: c.primary,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          AnimatedAlign(
            duration: _duration,
            curve: Curves.easeOutCubic,
            alignment: selected == HomeService.orders
                ? AlignmentDirectional.centerStart
                : AlignmentDirectional.centerEnd,
            child: FractionallySizedBox(
              widthFactor: 1 / HomeService.values.length,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: c.secondary,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
          ),
          Row(
            children: <Widget>[
              for (final HomeService service in HomeService.values)
                Expanded(
                  child: _Segment(
                    service: service,
                    isSelected: service == selected,
                    onTap: () => onChanged(service),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final HomeService service;
  final bool isSelected;
  final VoidCallback onTap;

  const _Segment({
    required this.service,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (IconData icon, String label) = switch (service) {
      HomeService.orders => (
        Icons.delivery_dining_rounded,
        Strings.homeServiceOrders,
      ),
      HomeService.parcels => (
        Icons.inventory_2_rounded,
        Strings.homeServiceParcels,
      ),
    };
    final Color color = isSelected
        ? Colors.white
        : Colors.white.withValues(alpha: 0.7);
    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isSelected ? null : onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 18.r, color: color),
            SizedBox(width: AppSpacing.xs.w),
            Flexible(
              child: AnimatedDefaultTextStyle(
                duration: HomeServiceToggle._duration,
                style: AppTextStyles.titleSmall(color: color),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
