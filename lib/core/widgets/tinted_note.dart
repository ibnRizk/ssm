import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// A short tinted-background informational strip — Pharmacy's price
/// disclaimer, Subscriptions' area-pricing footnote, Loyalty's "no
/// subscription needed" note, and any future single-line callout that isn't
/// severe enough for a full [AppDecorations.card] treatment. Pulled into
/// `core/` once the third screen needed the exact same shape, per the
/// project's "2+ places" rule for shared widgets.
class TintedNote extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const TintedNote({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md.w,
        vertical: AppSpacing.sm.h,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.md.r),
      ),
      child: Text(text, style: AppTextStyles.caption(color: textColor)),
    );
  }
}
