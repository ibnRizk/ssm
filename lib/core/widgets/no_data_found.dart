import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../utils/values/app_colors.dart';
import '../utils/values/strings.dart';
import '../utils/values/text_styles.dart';
import 'gaps.dart';

/// Compact empty state for lists and grids.
///
/// Pass [illustrationAsset] (an SVG path) to show artwork; without one it
/// falls back to an icon so the boilerplate ships with no bundled assets.
class NoDataFound extends StatelessWidget {
  final String? text;
  final String? illustrationAsset;

  const NoDataFound({super.key, this.text, this.illustrationAsset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (illustrationAsset != null)
            SvgPicture.asset(illustrationAsset!, height: 120.h)
          else
            Icon(
              Icons.inbox_outlined,
              size: 64.r,
              color: context.colors.textSecondary,
            ),
          Gaps.vGap12,
          Text(text ?? Strings.noDataFound, style: TextStyles.bold16()),
        ],
      ),
    );
  }
}
