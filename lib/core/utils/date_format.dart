import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/core/utils/string_extension.dart';
import '../../config/locale/app_localizations.dart';

class MyDate {
  static bool checkIfSame(String date, String selected) {
    DateTime date1 = DateFormat('yyyy-MM-dd').parse(date);
    DateTime date2 = DateFormat('yyyy-MM-dd').parse(selected);
    return date1.isSameDate(date2);
  }

  static String getNextMonth(String date) {
    DateTime parseDt = DateFormat('yyyy-MM-dd').parse(date);
    DateTime nextMonth = DateTime(parseDt.year, parseDt.month + 1, 1);
    String formated = DateFormat('yyyy-MM-dd').format(nextMonth);

    return formated;
  }

  static String getPreMonth(String date) {
    DateTime parseDt = DateFormat('yyyy-MM-dd').parse(date);
    DateTime nextMonth = DateTime(parseDt.year, parseDt.month - 1, 1);
    String formated = DateFormat('yyyy-MM-dd').format(nextMonth);

    return formated;
  }

  static String getMonthYear(String date, BuildContext context) {
    bool isRTL = AppLocalizations.of(context)!.isArLocale;

    DateTime parseDt = DateFormat('yyyy-MM-dd').parse(date);
    String formated = DateFormat.yMMMM(
      isRTL ? 'ar_SA' : 'en_US',
    ).format(parseDt);

    return formated;
  }

  static String getMonth(String date, BuildContext context) {
    bool isRTL = AppLocalizations.of(context)!.isArLocale;

    DateTime parseDt = DateFormat('yyyy-MM-dd').parse(date);
    String formated = DateFormat.MMMM(
      isRTL ? 'ar_SA' : 'en_US',
    ).format(parseDt);

    return formated;
  }

  static String getDay(String date, BuildContext context) {
    bool isRTL = AppLocalizations.of(context)!.isArLocale;

    DateTime parseDt = DateFormat('yyyy-MM-dd').parse(date);
    String formated = DateFormat.d(isRTL ? 'ar_SA' : 'en_US').format(parseDt);

    return formated;
  }

  static String getDayMonth(String date, BuildContext context) {
    bool isRTL = AppLocalizations.of(context)!.isArLocale;

    DateTime parseDt = DateFormat('yyyy-MM-dd').parse(date);
    String formated = DateFormat.yMMMd(
      isRTL ? 'ar_SA' : 'en_US',
    ).format(parseDt);

    return formated;
  }

  static String getAvailableDate(String date, BuildContext context) {
    bool isRTL = AppLocalizations.of(context)!.isArLocale;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    if (date.isNotEmpty) {
      DateTime parseDt = DateFormat('yyyy-MM-dd').parse(date);

      final aDate = DateTime(parseDt.year, parseDt.month, parseDt.day);
      if (aDate == today) {
        return AppLocalizations.of(context)!.text('today');
      } else if (aDate == tomorrow) {
        return AppLocalizations.of(context)!.text('tomorrow');
      } else {
        String formated = DateFormat.yMMMEd(
          isRTL ? 'ar_SA' : 'en_US',
        ).format(parseDt);
        return formated;
      }
    }
    return '';
  }

  static String getjm(String date, BuildContext context) {
    bool isRTL = AppLocalizations.of(context)!.isArLocale;

    DateTime parseDt = DateFormat('HH:mm:ss').parse(date);
    // String formated = DateFormat.jm(isRTL ? 'ar_SA' : 'en_US').format(parseDt);
    String formated = DateFormat(
      'hh:mm a',
      isRTL ? 'ar_SA' : 'en_US',
    ).format(parseDt);

    return formated;
  }

  static String getyMd(String date, BuildContext context) {
    bool isRTL = AppLocalizations.of(context)!.isArLocale;

    DateTime parseDt = DateFormat('yyyy-MM-dd HH:mm:ss').parse(date);
    String formated = DateFormat.yMMMd(
      isRTL ? 'ar_SA' : 'en_US',
    ).format(parseDt);
    return formated;
  }

  static String getHomeDate(String date, BuildContext context) {
    bool isRTL = AppLocalizations.of(context)!.isArLocale;

    DateTime parseDt = DateFormat('yyyy-MM-dd HH:mm:ss').parse(date);
    String formated = DateFormat.yMMMd(
      isRTL ? 'ar_SA' : 'en_US',
    ).format(parseDt);
    String day = DateFormat.EEEE(isRTL ? 'ar_SA' : 'en_US').format(parseDt);
    return '$formated ($day)';
  }

  static String getDayMonthTime(String date, BuildContext context) {
    bool isRTL = AppLocalizations.of(context)!.isArLocale;

    DateTime parseDt = DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').parse(date);
    String dateFormated = DateFormat.yMMMEd(
      isRTL ? 'ar_SA' : 'en_US',
    ).format(parseDt);
    String timeFormated = DateFormat.jm(
      isRTL ? 'ar_SA' : 'en_US',
    ).format(parseDt);
    String formated = '$dateFormated  $timeFormated';
    return formated;
  }

  static String getdateDiffrence(String date, String date2) {
    DateTime parseDt = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').parse(date);
    DateTime parseDt1 = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').parse(date2);
    int difference = parseDt1.difference(parseDt).inHours;
    return difference.toString();
  }

  DateTime findFirstDateOfTheWeek(DateTime dateTime) {
    return dateTime.subtract(Duration(days: dateTime.weekday - 1));
  }

  DateTime findLastDateOfTheWeek(DateTime dateTime) {
    return dateTime.add(
      Duration(days: DateTime.daysPerWeek - dateTime.weekday),
    );
  }

  String getFirstDayOfLast3Months() {
    DateTime now = DateTime.now();

    DateTime first = DateTime(now.year, now.month - 3, 1);

    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(first);
    return formatted;
  }

  String getLastDayOfLast3Months() {
    DateTime now = DateTime.now();
    int lastday = DateTime(now.year, now.month, 0).day;
    DateTime last = DateTime(now.year, now.month - 1, lastday);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(last);
    return formatted;
  }

  String getFirstDayOfLastYear() {
    DateTime now = DateTime.now();

    DateTime first = DateTime(now.year - 1, 1, 1);

    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(first);
    return formatted;
  }

  String getLastDayOfLastYear() {
    DateTime now = DateTime.now();
    DateTime last = DateTime(now.year - 1, 12, 31);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(last);
    return formatted;
  }

  String formateDate(DateTime date) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(date);
    return formatted;
  }

  String getFirstDayOfThisMonth() {
    final DateTime today = DateTime.now();
    final firstDay = DateTime(today.year, today.month, 1);
    final String fromDate = formateDate(firstDay);
    return fromDate;
  }

  String getLastDayOfThisMonth() {
    final DateTime today = DateTime.now();
    final String toDate = formateDate(today);
    return toDate;
  }

  String viewDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    final String formatted = formatter.format(date);
    return formatted;
  }

  static String getYearMounthDay(String date, BuildContext context) {
    bool isRTL = AppLocalizations.of(context)!.isArLocale;

    DateTime parseDt = DateFormat('yyyy-MM-dd HH:mm:ss').parse(date);
    String formated = DateFormat.yMMMEd(
      isRTL ? 'ar_SA' : 'en_US',
    ).format(parseDt);
    return formated;
  }
}
