import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/theme/app_theme.dart';
import 'package:ssm/core/utils/values/strings.dart';
import 'package:ssm/features/account/presentation/widgets/delete_account_dialog.dart';

import '../../helpers/test_strings.dart';

/// Opens the dialog and records what it returned.
Future<List<bool>> _openDialog(WidgetTester tester) async {
  final List<bool> results = <bool>[];
  // A phone, not the default 800×600 test surface.
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
                results.add(await confirmDeleteAccount(context)),
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

TextButton _confirmButton(WidgetTester tester) => tester.widget<TextButton>(
  find.widgetWithText(TextButton, Strings.accountDeleteConfirm),
);

void main() {
  setUpAll(installEnglishStrings);
  tearDownAll(removeTestStrings);

  testWidgets('the delete action is disabled until acknowledged', (
    WidgetTester tester,
  ) async {
    await _openDialog(tester);

    expect(_confirmButton(tester).onPressed, isNull);
  });

  testWidgets('ticking the acknowledgement enables it and confirms', (
    WidgetTester tester,
  ) async {
    final List<bool> results = await _openDialog(tester);

    await tester.tap(find.text(Strings.accountDeleteAcknowledge));
    await tester.pump();
    await tester.tap(find.text(Strings.accountDeleteConfirm));
    await tester.pumpAndSettle();

    expect(results, <bool>[true]);
  });

  testWidgets('cancel does not confirm', (WidgetTester tester) async {
    final List<bool> results = await _openDialog(tester);

    await tester.tap(find.text(Strings.cancel));
    await tester.pumpAndSettle();

    expect(results, <bool>[false]);
  });
}
