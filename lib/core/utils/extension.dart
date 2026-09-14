import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../injection_container.dart';
import 'values/app_colors.dart';

extension ImageExtension on num {
  /// Decode an image at the physical pixel size it will actually occupy,
  /// instead of its full resolution. Pass to `cacheWidth` / `cacheHeight`.
  int cacheSize(BuildContext context) =>
      (this * MediaQuery.of(context).devicePixelRatio).round();
}

extension StringExtension on String {
  Future<void> get launcherUrl async {
    final Uri? uri = Uri.tryParse(this);
    if (uri == null) throw 'Could not parse $this';
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $this';
    }
  }
}

extension DateTimeExtension on DateTime {
  int get lastDayOfMonth => DateTime(year, month + 1, 0).day;

  DateTime get lastDateOfMonth => DateTime(year, month + 1, 0);

  /// `yyyy-MM-dd` — the shape most APIs expect.
  String get displayDate =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  String get displayDateNamed => DateFormat.yMMMMd(
    appLocalizations.isArLocale ? 'ar_SA' : 'en_US',
  ).format(this);
}

extension FormDataExtension on FormData {
  /// Readable one-line dump for request logging — `FormData.toString()` is
  /// useless.
  String get toPrint {
    final List<String> parts = <String>[
      for (final MapEntry<String, String> item in fields)
        '${item.key}:${item.value}',
      for (final MapEntry<String, MultipartFile> item in files)
        '${item.key}:${item.value.filename}',
    ];
    return parts.toString();
  }
}

extension ColorFilterExtension on ColorFilter {
  /// Tints an SVG to the focus colour while its field has focus.
  static ColorFilter getFocusTextColor(
    FocusNode focusNode,
    BuildContext context,
  ) => ColorFilter.mode(
    focusNode.hasFocus ? context.colors.primary : context.colors.textPrimary,
    BlendMode.srcIn,
  );

  static ColorFilter setColor(Color color) =>
      ColorFilter.mode(color, BlendMode.srcIn);
}

extension CircularProgressIndicatorExtension on CircularProgressIndicator {
  /// Platform-adaptive spinner that keeps whatever properties were set.
  CircularProgressIndicator get appLoading {
    if (color != null) {
      return CircularProgressIndicator(
        key: key,
        strokeWidth: 2.w,
        valueColor: valueColor,
        color: color,
        backgroundColor: backgroundColor,
        semanticsLabel: semanticsLabel,
        semanticsValue: semanticsValue,
        value: value,
        strokeAlign: strokeAlign,
        strokeCap: strokeCap,
      );
    }
    return CircularProgressIndicator.adaptive(
      key: key,
      strokeWidth: 2.w,
      valueColor: valueColor,
      backgroundColor: backgroundColor,
      semanticsLabel: semanticsLabel,
      semanticsValue: semanticsValue,
      value: value,
      strokeAlign: strokeAlign,
      strokeCap: strokeCap,
    );
  }
}
