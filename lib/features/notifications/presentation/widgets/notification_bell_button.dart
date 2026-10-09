import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../cubit/notification_hub_cubit.dart';
import '../cubit/notification_hub_state.dart';

/// The inbox entry point with its unread badge. Needs the shell's
/// [NotificationHubCubit] above it; only the badge rebuilds on a new count.
class NotificationBellButton extends StatelessWidget {
  const NotificationBellButton({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return BlocSelector<NotificationHubCubit, NotificationHubState, int>(
      selector: (NotificationHubState state) => state.unreadCount,
      builder: (BuildContext context, int unread) => Semantics(
        button: true,
        label: unread > 0
            ? '${Strings.notificationsOpen}, $unread'
            : Strings.notificationsOpen,
        excludeSemantics: true,
        child: Material(
          color: c.surface,
          borderRadius: BorderRadius.circular(AppRadius.md.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.md.r),
            onTap: () => context.push(AppRoutes.notifications),
            child: Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md.r),
                border: Border.all(color: c.border),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: <Widget>[
                  Icon(
                    unread > 0
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_none_rounded,
                    color: c.textPrimary,
                    size: AppSizes.icon.r,
                  ),
                  PositionedDirectional(
                    top: -4.r,
                    end: -4.r,
                    child: _Badge(count: unread),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pops in and out with the count instead of blinking.
class _Badge extends StatelessWidget {
  final int count;

  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return AnimatedScale(
      scale: count > 0 ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      child: Container(
        constraints: BoxConstraints(minWidth: 18.r, minHeight: 18.r),
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        decoration: BoxDecoration(
          color: c.error,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          // Separates the badge from the bell's border.
          border: Border.all(color: c.surface, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          count > 99 ? '99+' : '$count',
          style: AppTextStyles.label(
            color: Colors.white,
          ).copyWith(fontSize: 10.sp, height: 1.2),
        ),
      ),
    );
  }
}
