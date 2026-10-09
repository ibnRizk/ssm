import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/app_notification.dart';
import '../utils/notification_navigation.dart';

/// One inbox row. Unread rows are tinted, titled in a heavier weight and
/// carry an orange dot; read rows sit flat on the card colour — so the
/// difference doesn't rely on colour alone.
class NotificationTile extends StatelessWidget {
  final AppNotification notification;

  /// Already formatted ("5 min ago"); null when the server sent no time.
  final String? timeLabel;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.timeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final bool unread = !notification.isRead;
    final BorderRadius radius = BorderRadius.circular(AppRadius.lg.r);

    return Semantics(
      hint: unread ? Strings.notificationsUnread : null,
      child: Material(
        color: unread ? c.primaryLight : c.surface,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(AppSpacing.md.r),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: unread ? c.primary.withValues(alpha: 0.12) : c.border,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _TargetIcon(notification: notification),
                SizedBox(width: AppSpacing.sm.w),
                Expanded(
                  child: _Texts(
                    notification: notification,
                    timeLabel: timeLabel,
                  ),
                ),
                SizedBox(width: AppSpacing.xs.w),
                // Fixed slot, so titles don't shift when a row turns read.
                SizedBox(
                  width: 10.r,
                  child: AnimatedOpacity(
                    opacity: unread ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: Container(
                        width: 10.r,
                        height: 10.r,
                        decoration: BoxDecoration(
                          color: c.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TargetIcon extends StatelessWidget {
  final AppNotification notification;

  const _TargetIcon({required this.notification});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final bool unread = !notification.isRead;
    return Container(
      width: 42.r,
      height: 42.r,
      decoration: BoxDecoration(
        color: unread ? c.secondaryLight : c.background,
        borderRadius: BorderRadius.circular(AppRadius.md.r),
      ),
      child: Icon(
        notificationTargetIcon(notification.target),
        size: 22.r,
        color: unread ? c.secondaryDark : c.textSecondary,
      ),
    );
  }
}

class _Texts extends StatelessWidget {
  final AppNotification notification;
  final String? timeLabel;

  const _Texts({required this.notification, required this.timeLabel});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final bool unread = !notification.isRead;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Text(
                notification.title.isEmpty
                    ? Strings.notificationsTitle
                    : notification.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: unread
                    ? AppTextStyles.title(color: c.textPrimary)
                    : AppTextStyles.bodyLarge(color: c.textPrimary),
              ),
            ),
            if (timeLabel case final String time) ...<Widget>[
              SizedBox(width: AppSpacing.xs.w),
              Text(
                time,
                style: AppTextStyles.caption(
                  color: unread ? c.primary : c.textHint,
                ),
              ),
            ],
          ],
        ),
        if (notification.body.isNotEmpty) ...<Widget>[
          SizedBox(height: AppSpacing.xxs.h),
          Text(
            notification.body,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body(color: c.textSecondary),
          ),
        ],
      ],
    );
  }
}
