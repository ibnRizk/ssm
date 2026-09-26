import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/order_list_entry.dart';

extension OrderListStatusLabels on OrderListStatus {
  String get label => switch (this) {
    OrderListStatus.pending => Strings.ordersStatusPending,
    OrderListStatus.preparing => Strings.ordersStatusPreparing,
    OrderListStatus.awaitingCourier => Strings.ordersStatusAwaitingCourier,
    OrderListStatus.onTheWay => Strings.ordersStatusOnTheWay,
    OrderListStatus.delivered => Strings.ordersStatusDelivered,
    OrderListStatus.cancelled => Strings.ordersStatusCancelled,
    OrderListStatus.refunded => Strings.ordersStatusRefunded,
  };

  /// A past order's badge: (background, text).
  (Color, Color) badgeColors(AppColors c) => switch (this) {
    OrderListStatus.delivered => (c.successLight, c.success),
    OrderListStatus.cancelled => (c.errorLight, c.error),
    OrderListStatus.refunded => (c.warningLight, c.warning),
    _ => (c.secondaryLight, c.secondary),
  };
}

extension OrderListEntryLabels on OrderListEntry {
  /// "Burger ×2 + Fries", or "8 items" when the list doesn't carry the
  /// products.
  String get itemsLabel {
    if (items.isNotEmpty) {
      return items
          .map(
            (OrderItemSummary i) =>
                i.quantity > 1 ? '${i.name} ×${i.quantity}' : i.name,
          )
          .join(' + ');
    }
    final int? count = itemCount;
    return count == null ? '' : Strings.ordersItemsCount(count);
  }

  String get amountLabel {
    final double? amount = orderAmount;
    return amount == null ? '' : formatSar(amount);
  }

  /// "Today, 8:24 PM · #1048" — the date part only when it's known.
  String dateAndNumber(DateTime now, String locale) {
    final DateTime? placed = createdAt;
    return <String>[
      if (placed != null) orderDateLabel(placed, now, locale),
      '#$id',
    ].join(' · ');
  }

  IconData get icon => switch (storeKind) {
    OrderStoreKind.food => Icons.lunch_dining,
    OrderStoreKind.grocery => Icons.shopping_cart_outlined,
    OrderStoreKind.pharmacy => Icons.medication_outlined,
    OrderStoreKind.other => Icons.receipt_long_outlined,
  };

  /// The icon tile on a white card: (background, icon).
  (Color, Color) iconColors(AppColors c) => switch (storeKind) {
    OrderStoreKind.food => (c.secondaryLight, c.secondary),
    OrderStoreKind.grocery => (c.info.withValues(alpha: 0.12), c.info),
    OrderStoreKind.pharmacy => (c.successLight, c.success),
    OrderStoreKind.other => (c.primaryLight, c.primary),
  };
}

/// "Today, 8:24 PM" / "Yesterday, 6:12 PM" / "18 August" / "18 Aug 2025",
/// relative to [now], in local time.
String orderDateLabel(DateTime placed, DateTime now, String locale) {
  final DateTime local = placed.toLocal();
  // Calendar days, compared in UTC so a DST shift can't skew the count.
  int day(DateTime d) =>
      DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;
  final int daysAgo = day(now) - day(local);
  final String time = DateFormat.jm(locale).format(local);
  if (daysAgo == 0) return Strings.ordersTodayAt(time);
  if (daysAgo == 1) return Strings.ordersYesterdayAt(time);
  return local.year == now.year
      ? DateFormat.MMMMd(locale).format(local)
      : DateFormat.yMMMd(locale).format(local);
}
