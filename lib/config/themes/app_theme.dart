import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/utils/values/app_colors.dart';
import '../../core/utils/values/fonts.dart';

/// Both themes are built from one function so light and dark can never drift.
///
/// These are getters, not constants: they use ScreenUtil (`.w/.h/.sp/.r`), so
/// they must be evaluated *inside* the `ScreenUtilInit` builder — which is
/// where `app.dart` reads them.
ThemeData get lightTheme =>
    _buildTheme(AppColors.light, Brightness.light);

ThemeData get darkTheme =>
    _buildTheme(AppColors.dark, Brightness.dark);

ThemeData _buildTheme(AppColors c, Brightness brightness) {
  final bool isDark = brightness == Brightness.dark;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: Fonts.primary,
    extensions: <ThemeExtension<dynamic>>[c],

    colorScheme: ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: Colors.white,
      primaryContainer: c.primaryLight,
      onPrimaryContainer: isDark
          ? Colors.white
          : c.primaryDark,
      secondary: c.secondary,
      onSecondary: Colors.white,
      surface: c.surface,
      onSurface: c.textPrimary,
      surfaceContainerHighest: c.background,
      onSurfaceVariant: c.textSecondary,
      outline: c.border,
      error: c.error,
      onError: Colors.white,
    ),

    scaffoldBackgroundColor: c.background,
    dividerTheme: DividerThemeData(
      thickness: 1,
      space: 1,
      color: c.border,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: c.primary,
    ),

    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      backgroundColor: c.surface,
      foregroundColor: c.textPrimary,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 64.h,
      iconTheme: IconThemeData(
        color: c.textPrimary,
        size: 24.r,
      ),
      actionsIconTheme: IconThemeData(
        color: c.textPrimary,
        size: 24.r,
      ),
      titleTextStyle: TextStyle(
        fontFamily: Fonts.primary,
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: c.textPrimary,
      ),
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
    ),

    cardTheme: CardThemeData(
      color: c.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: c.border),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 14.h,
      ),
      hintStyle: TextStyle(
        color: c.textSecondary,
        fontSize: 14.sp,
      ),
      border: _border(c.border, 12.r),
      enabledBorder: _border(c.border, 12.r),
      focusedBorder: _border(c.primary, 12.r, width: 1.5),
      errorBorder: _border(c.error, 12.r),
      focusedErrorBorder: _border(
        c.error,
        12.r,
        width: 1.5,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: c.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: c.border,
        elevation: 0,
        minimumSize: Size(double.infinity, 52.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        textStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: c.primary,
        minimumSize: Size(double.infinity, 52.h),
        side: BorderSide(color: c.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        textStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.primary,
        padding: EdgeInsets.zero,
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(padding: EdgeInsets.zero),
    ),

    checkboxTheme: CheckboxThemeData(
      checkColor: WidgetStateProperty.all<Color>(
        Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.r),
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: c.surface,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedItemColor: c.primary,
      unselectedItemColor: c.textSecondary,
      selectedLabelStyle: TextStyle(fontSize: 12.sp),
      unselectedLabelStyle: TextStyle(fontSize: 12.sp),
    ),

    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android:
            ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS:
            CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}

OutlineInputBorder _border(
  Color color,
  double radius, {
  double width = 1,
}) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(radius),
  borderSide: BorderSide(color: color, width: width),
);
