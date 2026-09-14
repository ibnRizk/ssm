import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_fonts.dart';
import 'app_text_styles.dart';

/// The SSM theme — light only, the design has no dark variant.
/// A getter, not a constant: it uses ScreenUtil (`.w/.h/.sp/.r`), so it must
/// be evaluated *inside* the `ScreenUtilInit` builder — which is where
/// `app.dart` reads it.
ThemeData get appTheme => _buildTheme(AppColors.light, Brightness.light);

/// The dark variant of the SSM theme.
ThemeData get appThemeDark => _buildTheme(AppColors.dark, Brightness.dark);

ThemeData _buildTheme(AppColors c, Brightness brightness) {
  final RoundedRectangleBorder buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadius.lg.r),
  );
  final Size buttonSize = Size(double.infinity, AppSizes.buttonHeight.h);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: AppFonts.primary,
    extensions: <ThemeExtension<dynamic>>[c],
    textTheme: _buildTextTheme(c),

    colorScheme: ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: Colors.white,
      primaryContainer: c.primaryLight,
      onPrimaryContainer: c.primaryDark,
      secondary: c.secondary,
      onSecondary: Colors.white,
      // Drives `FilledButton.tonal` — orange tint with dark-orange label.
      secondaryContainer: c.secondaryLight,
      onSecondaryContainer: c.secondaryDark,
      tertiary: c.accent,
      onTertiary: c.textPrimary,
      surface: c.surface,
      onSurface: c.textPrimary,
      surfaceContainerHighest: c.background,
      onSurfaceVariant: c.textSecondary,
      outline: c.border,
      outlineVariant: c.border,
      error: c.error,
      onError: Colors.white,
      errorContainer: c.errorLight,
      onErrorContainer: c.error,
      shadow: c.textPrimary,
    ),

    scaffoldBackgroundColor: c.background,
    iconTheme: IconThemeData(color: c.textPrimary, size: AppSizes.icon.r),
    dividerTheme: DividerThemeData(thickness: 1, space: 1, color: c.border),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: c.secondary,
      linearTrackColor: c.border,
    ),

    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      backgroundColor: c.background,
      foregroundColor: c.textPrimary,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 64.h,
      iconTheme: IconThemeData(color: c.textPrimary, size: AppSizes.icon.r),
      actionsIconTheme: IconThemeData(
        color: c.textPrimary,
        size: AppSizes.icon.r,
      ),
      titleTextStyle: AppTextStyles.h1(color: c.textPrimary),
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl.r),
        ),
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: AppTextStyles.h2(color: c.textPrimary),
      contentTextStyle: AppTextStyles.body(color: c.textSecondary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl.r),
      ),
    ),

    // Material elevation approximates the soft card shadow; for the exact
    // design shadow on Container-based cards use `AppDecorations.card`.
    cardTheme: CardThemeData(
      color: c.surface,
      elevation: 1,
      shadowColor: c.textPrimary.withValues(alpha: 0.3),
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md.w,
        vertical: AppSpacing.md.h,
      ),
      hintStyle: AppTextStyles.body(color: c.textHint),
      labelStyle: AppTextStyles.body(color: c.textSecondary),
      floatingLabelStyle: AppTextStyles.body(color: c.primary),
      errorStyle: AppTextStyles.caption(color: c.error),
      prefixIconColor: c.textSecondary,
      suffixIconColor: c.textSecondary,
      border: _border(c.border, AppRadius.lg.r),
      enabledBorder: _border(c.border, AppRadius.lg.r),
      disabledBorder: _border(c.border, AppRadius.lg.r),
      focusedBorder: _border(c.primary, AppRadius.lg.r, width: 1.5),
      errorBorder: _border(c.error, AppRadius.lg.r),
      focusedErrorBorder: _border(c.error, AppRadius.lg.r, width: 1.5),
    ),

    // Orange is the call-to-action colour on every screen of the design.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: c.secondary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: c.border,
        disabledForegroundColor: c.textHint,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: buttonSize,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w),
        shape: buttonShape,
        textStyle: AppTextStyles.button(),
      ),
    ),

    // Colours are left to the ColorScheme so `FilledButton` stays navy while
    // `FilledButton.tonal` picks up the secondary container tint.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: buttonSize,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w),
        shape: buttonShape,
        textStyle: AppTextStyles.button(),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: c.primary,
        minimumSize: buttonSize,
        side: BorderSide(color: c.primary),
        shape: buttonShape,
        textStyle: AppTextStyles.button(),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.secondary,
        padding: EdgeInsets.zero,
        textStyle: AppTextStyles.titleSmall(),
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(padding: EdgeInsets.zero),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) => states.contains(WidgetState.selected)
            ? c.secondary
            : Colors.transparent,
      ),
      checkColor: WidgetStateProperty.all<Color>(Colors.white),
      side: BorderSide(color: c.textHint, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
    ),

    // Filter chips: navy when selected, white otherwise.
    chipTheme: ChipThemeData(
      backgroundColor: c.surface,
      selectedColor: c.primary,
      disabledColor: c.border,
      showCheckmark: false,
      side: BorderSide.none,
      shape: const StadiumBorder(),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm.w,
        vertical: AppSpacing.xs.h,
      ),
      labelStyle: AppTextStyles.body(
        color: WidgetStateColor.resolveWith(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? Colors.white
              : c.textSecondary,
        ),
      ),
    ),

    tabBarTheme: TabBarThemeData(
      labelColor: c.textPrimary,
      unselectedLabelColor: c.textHint,
      labelStyle: AppTextStyles.titleSmall(),
      unselectedLabelStyle: AppTextStyles.body(),
      indicatorSize: TabBarIndicatorSize.label,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: c.secondary, width: 3),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      dividerColor: c.border,
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: c.surface,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedItemColor: c.secondary,
      unselectedItemColor: c.textHint,
      selectedLabelStyle: AppTextStyles.label(),
      unselectedLabelStyle: AppTextStyles.label().copyWith(
        fontWeight: FontWeight.w400,
      ),
    ),

    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}

/// Maps the semantic scale onto Material's slots so widgets that read
/// `Theme.of(context).textTheme` (and Material defaults) render in Cairo with
/// the design's sizes.
TextTheme _buildTextTheme(AppColors c) => TextTheme(
  displaySmall: AppTextStyles.display(color: c.textPrimary),
  headlineMedium: AppTextStyles.h1(color: c.textPrimary),
  titleLarge: AppTextStyles.h2(color: c.textPrimary),
  titleMedium: AppTextStyles.title(color: c.textPrimary),
  titleSmall: AppTextStyles.titleSmall(color: c.textPrimary),
  bodyLarge: AppTextStyles.bodyLarge(color: c.textPrimary),
  bodyMedium: AppTextStyles.body(color: c.textPrimary),
  bodySmall: AppTextStyles.caption(color: c.textSecondary),
  labelLarge: AppTextStyles.button(color: c.textPrimary),
  labelSmall: AppTextStyles.label(color: c.textSecondary),
);

OutlineInputBorder _border(Color color, double radius, {double width = 1}) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: width),
    );
