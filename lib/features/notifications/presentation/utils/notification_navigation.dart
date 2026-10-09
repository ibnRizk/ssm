import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/push/notification_target.dart';

/// Opens what a notification is about — from a tapped push or an inbox row.
///
/// Detail screens are pushed, so Back returns to where the customer was;
/// tabs are switched to, which also closes the inbox if it's on top.
/// [fromInbox] stops a generic notification re-opening the inbox it was
/// tapped in.
void openNotificationTarget(
  BuildContext context,
  NotificationTarget target, {
  bool fromInbox = false,
}) {
  final GoRouter router = GoRouter.of(context);
  switch (target) {
    case OrderTarget(:final int orderId):
      router.push(AppRoutes.orderTrackingPath(orderId));
    case ParcelsTarget():
      router.go(AppRoutes.parcels);
    case SubscriptionsTarget():
      router.go(AppRoutes.subscriptions);
    case InboxTarget():
      if (!fromInbox) router.push(AppRoutes.notifications);
  }
}

/// The icon a notification row shows for its target.
IconData notificationTargetIcon(NotificationTarget target) => switch (target) {
  OrderTarget() => Icons.receipt_long_rounded,
  ParcelsTarget() => Icons.inventory_2_rounded,
  SubscriptionsTarget() => Icons.star_rounded,
  InboxTarget() => Icons.notifications_rounded,
};
