import 'package:flutter/material.dart';

/// Raw brand palette. Swap these values per project — nothing else in the
/// boilerplate hardcodes a colour.
abstract class Palette {
  // Brand
  static const Color primary = Color(0xFF3A6FF7);
  static const Color primaryDark = Color(0xFF2450C8);
  static const Color primaryLight = Color(0xFFDCE6FF);
  static const Color secondary = Color(0xFF7A5AF8);

  // Neutrals — light
  static const Color background = Color(0xFFF6F7F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF14171F);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE4E7EC);

  // Neutrals — dark
  static const Color backgroundDark = Color(0xFF0F1115);
  static const Color surfaceDark = Color(0xFF181B22);
  static const Color textPrimaryDark = Color(0xFFF3F4F6);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color borderDark = Color(0xFF2A2F3A);

  // Semantic
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF2563EB);
}

/// Theme-aware colour set, exposed as a [ThemeExtension] so light/dark resolve
/// automatically.
///
/// Prefer `context.colors.primary` inside widgets. The context-free `colors`
/// getter in `injection_container.dart` is kept in sync from
/// `MaterialApp.builder` for code that has no [BuildContext].
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color error;
  final Color success;
  final Color warning;
  final Color info;

  const AppColors({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.error,
    required this.success,
    required this.warning,
    required this.info,
  });

  static const AppColors light = AppColors(
    primary: Palette.primary,
    primaryDark: Palette.primaryDark,
    primaryLight: Palette.primaryLight,
    secondary: Palette.secondary,
    background: Palette.background,
    surface: Palette.surface,
    textPrimary: Palette.textPrimary,
    textSecondary: Palette.textSecondary,
    border: Palette.border,
    error: Palette.error,
    success: Palette.success,
    warning: Palette.warning,
    info: Palette.info,
  );

  static const AppColors dark = AppColors(
    primary: Palette.primary,
    primaryDark: Palette.primaryDark,
    primaryLight: Palette.primaryDark,
    secondary: Palette.secondary,
    background: Palette.backgroundDark,
    surface: Palette.surfaceDark,
    textPrimary: Palette.textPrimaryDark,
    textSecondary: Palette.textSecondaryDark,
    border: Palette.borderDark,
    error: Palette.error,
    success: Palette.success,
    warning: Palette.warning,
    info: Palette.info,
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryDark,
    Color? primaryLight,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? error,
    Color? success,
    Color? warning,
    Color? info,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primaryLight: primaryLight ?? this.primaryLight,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      error: error ?? this.error,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }

  /// Value equality matters here: Flutter compares theme extensions to decide
  /// whether a theme change should trigger a rebuild. Without it, every
  /// `ThemeData` rebuild looks like a change.
  List<Object> get _props => <Object>[
    primary,
    primaryDark,
    primaryLight,
    secondary,
    background,
    surface,
    textPrimary,
    textSecondary,
    border,
    error,
    success,
    warning,
    info,
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppColors &&
          runtimeType == other.runtimeType &&
          _listEquals(_props, other._props);

  @override
  int get hashCode => Object.hashAll(_props);

  static bool _listEquals(List<Object> a, List<Object> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Preferred access inside widgets: `context.colors.primary`.
extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
