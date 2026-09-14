import 'package:flutter/material.dart';

/// Raw SSM brand palette, extracted from the client design flow. Nothing else
/// in the app hardcodes a colour — widgets read [AppColors] instead.
abstract class Palette {
  // Brand — navy
  static const Color primary = Color(0xFF173C66);
  static const Color primaryDark = Color(0xFF0F2A4A);
  static const Color primaryLight = Color(0xFFE8EEF5);

  // Brand — orange (every call to action)
  static const Color secondary = Color(0xFFF6921E);
  static const Color secondaryDark = Color(0xFFC96F0A);
  static const Color secondaryLight = Color(0xFFFEF1E1);

  /// Amber for prices and highlights sitting on navy surfaces.
  static const Color accent = Color(0xFFFFC47A);

  // Neutrals
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F1E3D);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7EB);

  // Semantic
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFDECEC);
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFE7F6ED);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFF4E0);
  static const Color info = Color(0xFF2563EB);

  // Shadows — navy-tinted so elevation reads clean on the light-gray
  // background instead of muddy gray.
  static const Color shadowSoft = Color(0x0F0F1E3D); // ~6%
  static const Color shadowHairline = Color(0x080F1E3D); // ~3%
}

/// Theme colour set, exposed as a [ThemeExtension].
///
/// Prefer `context.colors.primary` inside widgets. The context-free `colors`
/// getter in `injection_container.dart` is seeded with [AppColors.light] for
/// code that has no [BuildContext].
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color secondary;
  final Color secondaryDark;
  final Color secondaryLight;
  final Color accent;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color border;
  final Color error;
  final Color errorLight;
  final Color success;
  final Color successLight;
  final Color warning;
  final Color warningLight;
  final Color info;

  const AppColors({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.secondary,
    required this.secondaryDark,
    required this.secondaryLight,
    required this.accent,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.border,
    required this.error,
    required this.errorLight,
    required this.success,
    required this.successLight,
    required this.warning,
    required this.warningLight,
    required this.info,
  });

  static const AppColors light = AppColors(
    primary: Palette.primary,
    primaryDark: Palette.primaryDark,
    primaryLight: Palette.primaryLight,
    secondary: Palette.secondary,
    secondaryDark: Palette.secondaryDark,
    secondaryLight: Palette.secondaryLight,
    accent: Palette.accent,
    background: Palette.background,
    surface: Palette.surface,
    textPrimary: Palette.textPrimary,
    textSecondary: Palette.textSecondary,
    textHint: Palette.textHint,
    border: Palette.border,
    error: Palette.error,
    errorLight: Palette.errorLight,
    success: Palette.success,
    successLight: Palette.successLight,
    warning: Palette.warning,
    warningLight: Palette.warningLight,
    info: Palette.info,
  );

  /// The dark variant, retaining the core brand colours (navy/orange) while
  /// inverting the background and textual elements for night-time readability.
  static const AppColors dark = AppColors(
    primary: Palette.primary,
    primaryDark: Palette.primaryDark,
    primaryLight: Palette.primaryDark, // Muted for dark mode
    secondary: Palette.secondary,
    secondaryDark: Palette.secondaryDark,
    secondaryLight: Color(0xFF452B0F), // Darkened orange tint
    accent: Palette.accent,
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    textPrimary: Color(0xFFF9FAFB),
    textSecondary: Color(0xFF9CA3AF),
    textHint: Color(0xFF6B7280),
    border: Color(0xFF374151),
    error: Palette.error,
    errorLight: Color(0xFF450A0A),
    success: Palette.success,
    successLight: Color(0xFF064E3B),
    warning: Palette.warning,
    warningLight: Color(0xFF451A03),
    info: Palette.info,
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryDark,
    Color? primaryLight,
    Color? secondary,
    Color? secondaryDark,
    Color? secondaryLight,
    Color? accent,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? border,
    Color? error,
    Color? errorLight,
    Color? success,
    Color? successLight,
    Color? warning,
    Color? warningLight,
    Color? info,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primaryLight: primaryLight ?? this.primaryLight,
      secondary: secondary ?? this.secondary,
      secondaryDark: secondaryDark ?? this.secondaryDark,
      secondaryLight: secondaryLight ?? this.secondaryLight,
      accent: accent ?? this.accent,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      border: border ?? this.border,
      error: error ?? this.error,
      errorLight: errorLight ?? this.errorLight,
      success: success ?? this.success,
      successLight: successLight ?? this.successLight,
      warning: warning ?? this.warning,
      warningLight: warningLight ?? this.warningLight,
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
      secondaryDark: Color.lerp(secondaryDark, other.secondaryDark, t)!,
      secondaryLight: Color.lerp(secondaryLight, other.secondaryLight, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      border: Color.lerp(border, other.border, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorLight: Color.lerp(errorLight, other.errorLight, t)!,
      success: Color.lerp(success, other.success, t)!,
      successLight: Color.lerp(successLight, other.successLight, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningLight: Color.lerp(warningLight, other.warningLight, t)!,
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
    secondaryDark,
    secondaryLight,
    accent,
    background,
    surface,
    textPrimary,
    textSecondary,
    textHint,
    border,
    error,
    errorLight,
    success,
    successLight,
    warning,
    warningLight,
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
