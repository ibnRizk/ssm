import 'package:flutter/material.dart';
import 'package:ssm/core/theme/app_colors.dart';
import 'package:ssm/core/theme/app_decorations.dart';
import 'package:ssm/core/theme/app_text_styles.dart';
import 'package:ssm/core/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _designSize = Size(390, 844);

/// Pumps a minimal themed app on a design-sized surface — so ScreenUtil's
/// `.sp` scale is exactly 1 — and returns a context below the theme.
Future<BuildContext> _pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = _designSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  late BuildContext resolved;
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _designSize,
      builder: (_, __) => MaterialApp(
        theme: appTheme,
        home: Builder(
          builder: (BuildContext context) {
            resolved = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return resolved;
}

void main() {
  group('AppColors', () {
    test('primary is the brand navy', () {
      expect(AppColors.light.primary, const Color(0xFF173C66));
    });

    test('secondary is the brand orange', () {
      expect(AppColors.light.secondary, const Color(0xFFF6921E));
    });

    test('background is off-white', () {
      expect(AppColors.light.background, const Color(0xFFF8F9FA));
    });

    test('surface is pure white', () {
      expect(AppColors.light.surface, const Color(0xFFFFFFFF));
    });

    test('lerp endpoints round-trip', () {
      final AppColors other = AppColors.light.copyWith(
        primary: const Color(0xFF000000),
      );
      expect(AppColors.light.lerp(other, 0.0), AppColors.light);
      expect(AppColors.light.lerp(other, 1.0), other);
    });

    test('value equality holds', () {
      expect(AppColors.light, AppColors.light.copyWith());
      expect(AppColors.light.hashCode, AppColors.light.copyWith().hashCode);
      expect(
        AppColors.light,
        isNot(AppColors.light.copyWith(accent: const Color(0xFF000000))),
      );
    });
  });

  group('AppDecorations', () {
    // Regression test: `card()` used to hardcode `Palette.surface` (white)
    // regardless of theme, so every card built from it stayed white in dark
    // mode and swallowed the light text on top of it.
    testWidgets("card defaults to the given theme's surface colour", (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester);
      expect(AppDecorations.card(AppColors.light).color, AppColors.light.surface);
      expect(AppDecorations.card(AppColors.dark).color, AppColors.dark.surface);
      expect(
        AppDecorations.card(AppColors.dark).color,
        isNot(AppColors.light.surface),
      );
    });

    testWidgets('card respects an explicit colour override', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester);
      const Color override = Color(0xFF123456);
      expect(AppDecorations.card(AppColors.dark, color: override).color, override);
    });
  });

  group('Theme', () {
    testWidgets('exposes the AppColors extension', (WidgetTester tester) async {
      final BuildContext context = await _pumpApp(tester);
      expect(context.colors, AppColors.light);
    });

    testWidgets('scaffold uses the background colour', (
      WidgetTester tester,
    ) async {
      final BuildContext context = await _pumpApp(tester);
      expect(
        Theme.of(context).scaffoldBackgroundColor,
        AppColors.light.background,
      );
    });

    testWidgets('text renders in Cairo', (WidgetTester tester) async {
      final BuildContext context = await _pumpApp(tester);
      expect(Theme.of(context).textTheme.bodyMedium?.fontFamily, 'Cairo');
    });

    testWidgets('elevated buttons use the orange action colour', (
      WidgetTester tester,
    ) async {
      final BuildContext context = await _pumpApp(tester);
      final Color? background = Theme.of(
        context,
      ).elevatedButtonTheme.style?.backgroundColor?.resolve(<WidgetState>{});
      expect(background, AppColors.light.secondary);
    });
  });

  group('AppTextStyles', () {
    testWidgets('h1 is 24 bold', (WidgetTester tester) async {
      await _pumpApp(tester);
      final TextStyle style = AppTextStyles.h1();
      expect(style.fontSize, 24);
      expect(style.fontWeight, FontWeight.w700);
    });

    testWidgets('h2 is 18 bold', (WidgetTester tester) async {
      await _pumpApp(tester);
      final TextStyle style = AppTextStyles.h2();
      expect(style.fontSize, 18);
      expect(style.fontWeight, FontWeight.w700);
    });

    testWidgets('body is 14 medium', (WidgetTester tester) async {
      await _pumpApp(tester);
      final TextStyle style = AppTextStyles.body();
      expect(style.fontSize, 14);
      expect(style.fontWeight, FontWeight.w500);
    });

    testWidgets('caption is 12 regular', (WidgetTester tester) async {
      await _pumpApp(tester);
      final TextStyle style = AppTextStyles.caption();
      expect(style.fontSize, 12);
      expect(style.fontWeight, FontWeight.w400);
    });
  });
}
