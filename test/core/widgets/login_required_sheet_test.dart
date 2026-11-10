import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/theme/app_theme.dart';
import 'package:ssm/core/utils/values/strings.dart';
import 'package:ssm/core/widgets/login_required_sheet.dart';

import '../../helpers/test_strings.dart';

/// Opens the sheet and records what it returned.
Future<List<LoginRequiredChoice?>> _openSheet(WidgetTester tester) async {
  final List<LoginRequiredChoice?> results = <LoginRequiredChoice?>[];
  tester.view
    ..physicalSize = const Size(1170, 2532)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) => MaterialApp(
        theme: appTheme,
        home: Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () async =>
                results.add(await showLoginRequiredSheet(context)),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return results;
}

void main() {
  setUpAll(installEnglishStrings);
  tearDownAll(removeTestStrings);

  testWidgets('shows the title and message', (WidgetTester tester) async {
    await _openSheet(tester);

    expect(find.text(Strings.signInRequiredTitle), findsOneWidget);
    expect(find.text(Strings.signInRequiredMessage), findsOneWidget);
  });

  testWidgets('Login returns login', (WidgetTester tester) async {
    final List<LoginRequiredChoice?> results = await _openSheet(tester);

    await tester.tap(find.text(Strings.authLoginButton));
    await tester.pumpAndSettle();

    expect(results, <LoginRequiredChoice?>[LoginRequiredChoice.login]);
  });

  testWidgets('Create account returns createAccount', (
    WidgetTester tester,
  ) async {
    final List<LoginRequiredChoice?> results = await _openSheet(tester);

    await tester.tap(find.text(Strings.signInRequiredCreateAccount));
    await tester.pumpAndSettle();

    expect(results, <LoginRequiredChoice?>[LoginRequiredChoice.createAccount]);
  });

  testWidgets('Not now returns nothing', (WidgetTester tester) async {
    final List<LoginRequiredChoice?> results = await _openSheet(tester);

    await tester.tap(find.text(Strings.notNow));
    await tester.pumpAndSettle();

    expect(results, <LoginRequiredChoice?>[null]);
  });
}
