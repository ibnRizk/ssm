import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../theme/app_colors.dart';
import 'enums.dart';

/// Shimmer base/highlight, kept here so [AppShimmer] has no colour of its own.
const Color baseColorShimmer = Color(0xFFE9EBEF);
const Color highlightColorShimmer = Color(0xFFF6F7F9);

/// Device language as a [LanguageCode], used to seed the locale on first run.
LanguageCode getSystemLang() {
  final String code = ui.PlatformDispatcher.instance.locale.languageCode;
  return LanguageCode.values.firstWhere(
    (LanguageCode e) => e.name == code,
    orElse: () => LanguageCode.en,
  );
}

/// Initials for avatar placeholders: "Ada Lovelace" -> "AL".
String getInitials(String name, {int limit = 2}) {
  final List<String> parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((String p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '';
  return parts
      .take(limit)
      .map((String p) => p.characters.first.toUpperCase())
      .join();
}

/// Blocking spinner. Always pair with [hideLoading] in a `finally`.
void showLoading(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) => PopScope(
      canPop: false,
      child: Center(
        child: CircularProgressIndicator(color: ctx.colors.primary),
      ),
    ),
  );
}

void hideLoading(BuildContext context) {
  if (Navigator.of(context, rootNavigator: true).canPop()) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

enum ToastKind { success, error, warning, info }

void showToast(String message, {ToastKind kind = ToastKind.info}) {
  final Color background = switch (kind) {
    ToastKind.success => Palette.success,
    ToastKind.error => Palette.error,
    ToastKind.warning => Palette.warning,
    ToastKind.info => Palette.info,
  };
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: background,
    textColor: Colors.white,
  );
}

/// Eastern-Arabic numerals, for locales that render them.
const List<String> arabicNumerals = <String>[
  '٠',
  '١',
  '٢',
  '٣',
  '٤',
  '٥',
  '٦',
  '٧',
  '٨',
  '٩',
];
