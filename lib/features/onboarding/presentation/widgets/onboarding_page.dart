import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_network_image.dart';

/// One onboarding slide's content.
class OnboardingSlide {
  /// Null shows the branded fallback (tests, or a slide without a photo).
  final String? imageUrl;
  final IconData icon;
  final String title;
  final String body;

  const OnboardingSlide({
    this.imageUrl,
    required this.icon,
    required this.title,
    required this.body,
  });
}

/// A full-bleed photo with a rounded bottom edge, an icon chip riding the
/// seam, then the title and body.
class OnboardingPage extends StatelessWidget {
  final OnboardingSlide slide;

  const OnboardingPage({super.key, required this.slide});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Size screen = MediaQuery.sizeOf(context);
    final double imageHeight = screen.height * 0.56;
    final double chip = 64.r;
    return Column(
      children: <Widget>[
        SizedBox(
          height: imageHeight + chip / 2,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              AppNetworkImage(
                url: slide.imageUrl,
                width: screen.width,
                height: imageHeight,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(AppRadius.xxl.r * 1.5),
                ),
                fallback: _ImageFallback(icon: slide.icon),
              ),
              // Darkens the top so the Skip button stays legible on any photo.
              Positioned.fill(
                bottom: chip / 2,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(AppRadius.xxl.r * 1.5),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                        colors: <Color>[
                          Colors.black.withValues(alpha: 0.35),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: chip,
                    height: chip,
                    decoration: BoxDecoration(
                      color: c.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(color: c.surface, width: 4),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: c.secondary.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(slide.icon, color: Colors.white, size: 28.r),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.lg.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl.w),
          child: Column(
            children: <Widget>[
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style: AppTextStyles.h1(color: c.textPrimary),
              ),
              SizedBox(height: AppSpacing.sm.h),
              Text(
                slide.body,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge(color: c.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Shown while the photo loads, or if it can't — a brand gradient, so a
/// slow or dead link never leaves a hole.
class _ImageFallback extends StatelessWidget {
  final IconData icon;

  const _ImageFallback({required this.icon});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[c.primary, c.primaryDark],
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 96.r,
          color: Colors.white.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}
