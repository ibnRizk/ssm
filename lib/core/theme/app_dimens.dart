// Design units, relative to `kDesignSize` in app.dart. Apply ScreenUtil at the
// call site: `EdgeInsets.all(AppSpacing.md.w)`, `Radius.circular(AppRadius.lg.r)`.

/// Spacing scale.
abstract class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;

  /// Horizontal gutter between the screen edge and content.
  static const double screen = md;
}

/// Corner radii.
abstract class AppRadius {
  static const double sm = 8; // qty steppers, small tags
  static const double md = 12; // icon chips, small tiles
  static const double lg = 16; // cards, buttons, inputs
  static const double xl = 20; // hero banners, dialogs
  static const double xxl = 24; // bottom-sheet top corners
  static const double pill = 999; // chips, badges
}

/// Fixed component sizes.
abstract class AppSizes {
  static const double buttonHeight = 52;
  static const double icon = 24;
}
