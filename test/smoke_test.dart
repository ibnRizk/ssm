import 'package:flutter/material.dart';
import 'package:flutter_base/config/themes/app_theme.dart';
import 'package:flutter_base/core/utils/values/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps a minimal app in [mode] and returns the resolved [AppColors].
Future<AppColors> _resolveColors(WidgetTester tester, ThemeMode mode) async {
  late AppColors resolved;
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) => MaterialApp(
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: mode,
        home: Builder(
          builder: (BuildContext context) {
            resolved = context.colors;
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );
  // Theme changes animate; settle so we read the endpoint, not a lerp frame.
  await tester.pumpAndSettle();
  return resolved;
}

void main() {
  group('AppColors', () {
    test('lerp endpoints round-trip', () {
      expect(AppColors.light.lerp(AppColors.dark, 0.0), AppColors.light);
      expect(AppColors.light.lerp(AppColors.dark, 1.0), AppColors.dark);
    });

    test('light and dark use distinct neutrals', () {
      expect(AppColors.light.surface, isNot(AppColors.dark.surface));
      expect(AppColors.light.textPrimary, isNot(AppColors.dark.textPrimary));
    });

    test('value equality holds', () {
      expect(AppColors.light, AppColors.light.copyWith());
      expect(AppColors.light.hashCode, AppColors.light.copyWith().hashCode);
      expect(AppColors.light, isNot(AppColors.dark));
    });
  });

  group('Theme', () {
    testWidgets('light theme exposes the AppColors extension', (
      WidgetTester tester,
    ) async {
      expect(await _resolveColors(tester, ThemeMode.light), AppColors.light);
    });

    testWidgets('dark theme exposes the AppColors extension', (
      WidgetTester tester,
    ) async {
      expect(await _resolveColors(tester, ThemeMode.dark), AppColors.dark);
    });
  });
}
