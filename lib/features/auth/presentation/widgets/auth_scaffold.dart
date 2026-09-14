import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/values/app_assets.dart';

/// Shared shell for the auth screens: a white, rounded-top card floating
/// over the app's navy background, with the SSM logo straddling the seam
/// between the two. Login and Register both wrap their content in this so
/// the two screens share one visual identity.
class AuthScaffold extends StatelessWidget {
  final Widget child;

  const AuthScaffold({super.key, required this.child});

  static const double _headerHeight = 120;
  static const double _logoDiameter = 84;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.primary,
      body: Stack(
        clipBehavior: Clip.hardEdge,
        children: <Widget>[
          Positioned(
            top: -70.r,
            right: -60.r,
            child: Container(
              width: 220.r,
              height: 220.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Column(
            children: <Widget>[
              SizedBox(height: _headerHeight.h),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppRadius.xxl.r),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.xl.w,
                        _logoDiameter.h / 2 + AppSpacing.lg.h,
                        AppSpacing.xl.w,
                        AppSpacing.lg.h,
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: (_headerHeight - _logoDiameter / 2).h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: _logoDiameter.r,
                height: _logoDiameter.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(AppAssets.logo, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
