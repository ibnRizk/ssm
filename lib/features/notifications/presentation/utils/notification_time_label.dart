import 'package:intl/intl.dart';

import '../../../../core/utils/values/strings.dart';

/// A row's time: relative while recent ("5 min ago"), then "Yesterday",
/// then a short date. [languageCode] picks the date's language.
String notificationTimeLabel(
  DateTime time, {
  required DateTime now,
  required String languageCode,
}) {
  final Duration age = now.difference(time);
  // A clock skewed ahead of the device's still reads as "just now".
  if (age.inMinutes < 1) {
    return Strings.notificationsTimeNow;
  }
  if (age.inMinutes < 60) {
    return Strings.notificationsTimeMinutes(age.inMinutes);
  }

  final DateTime today = DateTime(
    now.year,
    now.month,
    now.day,
  );
  final DateTime day = DateTime(
    time.year,
    time.month,
    time.day,
  );
  final int daysAgo = today.difference(day).inDays;
  if (daysAgo == 0) {
    return Strings.notificationsTimeHours(age.inHours);
  }
  if (daysAgo == 1) {
    return Strings.notificationsTimeYesterday;
  }

  final DateFormat format = time.year == now.year
      ? DateFormat.MMMd(languageCode)
      : DateFormat.yMMMd(languageCode);
  return format.format(time);
}
