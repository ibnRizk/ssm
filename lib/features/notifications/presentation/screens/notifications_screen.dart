import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/error_text.dart';
import '../../../../core/widgets/load_more_footer.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../../domain/entities/app_notification.dart';
import '../cubit/notifications_cubit.dart';
import '../cubit/notifications_state.dart';
import '../utils/notification_navigation.dart';
import '../utils/notification_time_label.dart';
import '../widgets/notification_tile.dart';
import '../widgets/notifications_empty_view.dart';
import '../widgets/notifications_skeleton.dart';

/// The in-app inbox. Pushed from the bell (outside the shell, so no bottom
/// navigation) with its own [NotificationsCubit].
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: SimpleAppBar(
        title: Strings.notificationsTitle,
        onBack: () => context.pop(),
        trailing: const _MarkAllReadButton(),
      ),
      body: BlocListener<NotificationsCubit, NotificationsState>(
        listenWhen: (_, NotificationsState state) =>
            state is NotificationsLoaded && state.actionFailure != null,
        listener: (_, __) => showToast(
          Strings.notificationsMarkAllFailed,
          kind: ToastKind.error,
        ),
        child: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (BuildContext context, NotificationsState state) =>
              switch (state) {
                NotificationsInitial() ||
                NotificationsLoading() => const NotificationsSkeleton(),
                NotificationsError(:final failure) => ErrorText(
                  message: failure.userMessage,
                  onRetry: () => context.read<NotificationsCubit>().load(),
                ),
                NotificationsLoaded() => RefreshIndicator(
                  onRefresh: () => context.read<NotificationsCubit>().refresh(),
                  child: state.items.isEmpty
                      ? const NotificationsEmptyView()
                      : _NotificationsList(state: state),
                ),
              },
        ),
      ),
    );
  }
}

class _NotificationsList extends StatelessWidget {
  final NotificationsLoaded state;

  const _NotificationsList({required this.state});

  /// Start fetching the next page this far before the end.
  static const double _loadMoreThreshold = 300;

  @override
  Widget build(BuildContext context) {
    final NotificationsCubit cubit = context.read<NotificationsCubit>();
    final String languageCode = Localizations.localeOf(context).languageCode;
    final DateTime now = DateTime.now();

    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (ScrollUpdateNotification notification) {
        if (notification.metrics.extentAfter < _loadMoreThreshold) {
          cubit.loadMore();
        }
        return false;
      },
      child: ListView.separated(
        // Pull-to-refresh must work even on a short list.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screen.w,
          AppSpacing.md.h,
          AppSpacing.screen.w,
          AppSpacing.xxl.h,
        ),
        // The last row is the paging footer.
        itemCount: state.items.length + 1,
        separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm.h),
        itemBuilder: (BuildContext context, int index) {
          if (index == state.items.length) {
            return LoadMoreFooter(
              status: state.loadMore,
              onRetry: cubit.loadMore,
            );
          }
          final AppNotification notification = state.items[index];
          final DateTime? time = notification.timestamp;
          return NotificationTile(
            key: ValueKey<String>(notification.id),
            notification: notification,
            timeLabel: time == null
                ? null
                : notificationTimeLabel(
                    time,
                    now: now,
                    languageCode: languageCode,
                  ),
            onTap: () {
              cubit.markRead(notification);
              openNotificationTarget(
                context,
                notification.target,
                fromInbox: true,
              );
            },
          );
        },
      ),
    );
  }
}

/// Shown only while something is unread; only this rebuilds when that
/// changes.
class _MarkAllReadButton extends StatelessWidget {
  const _MarkAllReadButton();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return BlocSelector<NotificationsCubit, NotificationsState, bool>(
      selector: (NotificationsState state) =>
          state is NotificationsLoaded && state.hasUnread,
      builder: (BuildContext context, bool hasUnread) => AnimatedOpacity(
        opacity: hasUnread ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: IconButton(
          tooltip: Strings.notificationsMarkAllRead,
          onPressed: hasUnread
              ? () => context.read<NotificationsCubit>().markAllRead()
              : null,
          icon: Icon(Icons.done_all_rounded, color: c.primary),
        ),
      ),
    );
  }
}
