import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/app_assets.dart';
import '../../../../core/utils/values/strings.dart';

/// How long the boot animation runs. Kept in one place so the progress bar's
/// fill and the navigation delay below can never drift apart.
const Duration _bootDuration = Duration(milliseconds: 1400);

/// Boot screen. Do warm-up work here — session restore, remote config,
/// force-update check — then route based on the result.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this, duration: _bootDuration)
      ..forward();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Replace with real startup work. Branch on
    // `sharedPreferences.getUserCycle()` once you have onboarding/auth.
    await Future<void>.delayed(_bootDuration);
    if (!mounted) return;
    context.goNamed(AppRoutes.homeName);
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.primary,
      body: Stack(
        clipBehavior: Clip.hardEdge,
        children: <Widget>[
          const _TopLeftGlow(),
          const _BottomRightBlob(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w),
              child: Column(
                children: <Widget>[
                  const Spacer(flex: 3),
                  const _Logo(),
                  SizedBox(height: AppSpacing.xl.h),
                  Text(
                    Strings.appName,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.display(color: Colors.white),
                  ),
                  SizedBox(height: AppSpacing.xs.h),
                  Text(
                    Strings.splashTagline,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxs.h),
                  Text(
                    Strings.splashSubtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.title(color: context.colors.secondary),
                  ),
                  const Spacer(flex: 4),
                  AnimatedBuilder(
                    animation: _progress,
                    builder: (_, __) => _ProgressBar(value: _progress.value),
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  Text(
                    Strings.splashLoading,
                    style: AppTextStyles.caption(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxl.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Brand mark: the bundled logo asset in a circular frame. The bezel/ring is
/// already baked into `icon.jpeg`; this just clips away its square corners
/// and lifts it off the navy background with a soft shadow.
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    final double diameter = 140.r;
    return Container(
      width: diameter,
      height: diameter,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipOval(child: Image.asset(AppAssets.logo, fit: BoxFit.cover)),
    );
  }
}

/// Faint concentric arcs bleeding off the top-left edge.
class _TopLeftGlow extends StatelessWidget {
  const _TopLeftGlow();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -120.r,
      left: -120.r,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[_ring(280.r, 0.05), _ring(210.r, 0.09)],
      ),
    );
  }

  Widget _ring(double diameter, double opacity) => Container(
    width: diameter,
    height: diameter,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withValues(alpha: opacity)),
    ),
  );
}

/// Solid brand-orange shape anchored to the bottom-right corner.
class _BottomRightBlob extends StatelessWidget {
  const _BottomRightBlob();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: -90.r,
      right: -70.r,
      child: Container(
        width: 260.r,
        height: 260.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colors.secondary,
        ),
      ),
    );
  }
}

/// Translucent track, solid orange fill, pill-shaped.
class _ProgressBar extends StatelessWidget {
  final double value;

  const _ProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 6.h,
        backgroundColor: Colors.white.withValues(alpha: 0.25),
        valueColor: AlwaysStoppedAnimation<Color>(context.colors.secondary),
      ),
    );
  }
}
