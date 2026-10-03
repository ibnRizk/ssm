import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/values/app_assets.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../injection_container.dart';
import '../cubit/splash_cubit.dart';
import '../cubit/splash_state.dart';

/// How long the boot animation runs. Kept in one place so the progress bar's
/// fill and the minimum wait in [SplashCubit.start] can never drift apart.
const Duration _bootDuration = Duration(milliseconds: 1400);

/// Boot screen: checks the backend config (force update, maintenance) while
/// the animation runs, then routes on the session.
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
    _progress = AnimationController(vsync: this, duration: _bootDuration);
    _start();
  }

  /// Also the maintenance screen's retry.
  void _start() {
    _progress.forward(from: 0);
    context.read<SplashCubit>().start(minimumDuration: _bootDuration);
  }

  Future<void> _enterApp() async {
    final String? token = await secureStorage.getAccessToken();
    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      context.goNamed(AppRoutes.homeName);
    } else {
      context.goNamed(AppRoutes.loginName);
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listenWhen: (_, SplashState state) => state is SplashReady,
      listener: (_, __) => _enterApp(),
      child: Scaffold(
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
                      style: AppTextStyles.title(
                        color: context.colors.secondary,
                      ),
                    ),
                    const Spacer(flex: 4),
                    _SplashFooter(progress: _progress, onRetry: _start),
                    SizedBox(height: AppSpacing.xxl.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The progress bar while checking; in its place, what blocks entry.
class _SplashFooter extends StatelessWidget {
  final Animation<double> progress;
  final VoidCallback onRetry;

  const _SplashFooter({required this.progress, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SplashCubit, SplashState>(
      builder: (_, SplashState state) => switch (state) {
        SplashLoading() || SplashReady() => _Progress(progress: progress),
        SplashUpdateRequired(:final String? storeUrl) => _GateMessage(
          title: Strings.splashUpdateTitle,
          message: Strings.splashUpdateMessage,
          // Without a store link the message alone tells them what to do.
          actionLabel: storeUrl == null ? null : Strings.splashUpdateButton,
          onAction: storeUrl == null ? null : () => _openStore(storeUrl),
        ),
        SplashMaintenance() => _GateMessage(
          title: Strings.splashMaintenanceTitle,
          message: Strings.splashMaintenanceMessage,
          actionLabel: Strings.retry,
          onAction: onRetry,
        ),
      },
    );
  }

  static Future<void> _openStore(String url) async {
    final bool opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!opened) showToast(Strings.somethingWentWrong, kind: ToastKind.error);
  }
}

class _Progress extends StatelessWidget {
  final Animation<double> progress;

  const _Progress({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: progress,
          builder: (_, __) => _ProgressBar(value: progress.value),
        ),
        SizedBox(height: AppSpacing.sm.h),
        Text(
          Strings.splashLoading,
          style: AppTextStyles.caption(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _GateMessage extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _GateMessage({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.title(color: Colors.white),
        ),
        SizedBox(height: AppSpacing.xs.h),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge(
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
        if (actionLabel != null) ...<Widget>[
          SizedBox(height: AppSpacing.lg.h),
          AppButton(btnText: actionLabel, onPressed: onAction),
        ],
      ],
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
