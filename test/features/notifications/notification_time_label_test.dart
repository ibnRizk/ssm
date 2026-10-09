import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ssm/features/notifications/presentation/utils/notification_time_label.dart';

import '../../helpers/test_strings.dart';

final DateTime _now = DateTime(2026, 10, 9, 15, 30);

String _label(DateTime time) =>
    notificationTimeLabel(time, now: _now, languageCode: 'en');

void main() {
  setUpAll(() async {
    installEnglishStrings();
    await initializeDateFormatting('en');
  });

  tearDownAll(removeTestStrings);

  test('under a minute reads as just now', () {
    expect(_label(_now.subtract(const Duration(seconds: 30))), 'Just now');
  });

  test('a time slightly in the future reads as just now', () {
    expect(_label(_now.add(const Duration(minutes: 2))), 'Just now');
  });

  test('minutes within the hour', () {
    expect(_label(_now.subtract(const Duration(minutes: 5))), '5 min ago');
  });

  test('hours earlier today', () {
    expect(_label(DateTime(2026, 10, 9, 10, 0)), '5 h ago');
  });

  test('any time yesterday reads as yesterday', () {
    expect(_label(DateTime(2026, 10, 8, 23, 59)), 'Yesterday');
  });

  test('older this year shows month and day', () {
    expect(_label(DateTime(2026, 9, 1)), 'Sep 1');
  });

  test('an earlier year includes the year', () {
    expect(_label(DateTime(2025, 9, 1)), 'Sep 1, 2025');
  });
}
