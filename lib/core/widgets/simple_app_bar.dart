import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// The white "centered title + circular back button" app bar used by every
/// pushed inner screen (Cart, Order Confirmation, Order Tracking, …). Pulled
/// into `core/` once the third screen needed the exact same bar, per the
/// project's "2+ places" rule for shared widgets.
class SimpleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;

  /// Optional end-side content (e.g. a status badge) — see Loyalty's "متاح
  /// للجميع" pill. Wrapped in the same padding `actions` normally gets.
  final Widget? trailing;

  const SimpleAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return AppBar(
      backgroundColor: c.surface,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(title, style: AppTextStyles.h2(color: c.textPrimary)),
      actions: trailing == null
          ? null
          : <Widget>[
              Padding(
                padding: EdgeInsetsDirectional.only(end: 12.w),
                child: Center(child: trailing!),
              ),
            ],
      // `Center`, not `Padding`: the AppBar gives `leading` a fixed-size
      // slot, and without a widget that lets its child size itself within
      // that slot, the explicit 40.r below would be overridden by the
      // slot's own tight constraints instead of rendering as a neat circle.
      leading: Center(
        child: GestureDetector(
          onTap: onBack,
          child: Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: c.border),
            ),
            child: Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_forward
                  : Icons.arrow_back,
              size: 18.r,
              color: c.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
