import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../widgets/onboarding_page.dart';

/// First-launch introduction. Finishing or skipping enters Home as a guest
/// — no sign-in on the way (App Store guideline 5.1.1(v)); account-based
/// features ask for it when they're opened.
///
/// The current page is local UI state: a [ValueNotifier] rebuilds only the
/// dots and the button, never the pages.
class OnboardingScreen extends StatefulWidget {
  /// The default introduction when null; tests pass their own.
  final List<OnboardingSlide>? slides;

  const OnboardingScreen({super.key, this.slides});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Unsplash (free licence). Sized for phones; cached after the first load.
  static const String _imageParams = '?w=1080&q=80&fm=jpg&fit=crop';

  static List<OnboardingSlide> get _slides => <OnboardingSlide>[
    OnboardingSlide(
      imageUrl:
          'https://images.unsplash.com/photo-1617347454431-f49d7ff5c3b1'
          '$_imageParams',
      icon: Icons.storefront_rounded,
      title: Strings.onboardingTitle1,
      body: Strings.onboardingBody1,
    ),
    OnboardingSlide(
      imageUrl:
          'https://images.unsplash.com/photo-1566576721346-d4a3b4eaeb55'
          '$_imageParams',
      icon: Icons.inventory_2_rounded,
      title: Strings.onboardingTitle2,
      body: Strings.onboardingBody2,
    ),
    OnboardingSlide(
      imageUrl:
          'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d'
          '$_imageParams',
      icon: Icons.location_on_rounded,
      title: Strings.onboardingTitle3,
      body: Strings.onboardingBody3,
    ),
  ];

  late final List<OnboardingSlide> _pages = widget.slides ?? _slides;
  final PageController _controller = PageController();
  final ValueNotifier<int> _page = ValueNotifier<int>(0);
  bool _leaving = false;

  @override
  void dispose() {
    _controller.dispose();
    _page.dispose();
    super.dispose();
  }

  bool get _onLastPage => _page.value == _pages.length - 1;

  void _next() {
    if (_onLastPage) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _finish({String destination = AppRoutes.homeName}) async {
    if (_leaving) return;
    _leaving = true;
    await context.read<SessionCubit>().completeOnboarding();
    if (mounted) context.goNamed(destination);
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Scaffold(
      backgroundColor: c.surface,
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (int index) => _page.value = index,
                  itemBuilder: (_, int index) =>
                      OnboardingPage(slide: _pages[index]),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xl.w,
                    AppSpacing.md.h,
                    AppSpacing.xl.w,
                    AppSpacing.md.h,
                  ),
                  child: ValueListenableBuilder<int>(
                    valueListenable: _page,
                    builder: (_, int page, _) => Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _Dots(count: _pages.length, current: page),
                        SizedBox(height: AppSpacing.xl.h),
                        AppButton(
                          btnText: page == _pages.length - 1
                              ? Strings.onboardingGetStarted
                              : Strings.onboardingNext,
                          height: AppSizes.buttonHeight.h,
                          borderRadius: AppRadius.lg.r,
                          onPressed: _next,
                        ),
                        TextButton(
                          onPressed: () =>
                              _finish(destination: AppRoutes.loginName),
                          style: TextButton.styleFrom(
                            foregroundColor: c.textSecondary,
                          ),
                          child: Text.rich(
                            TextSpan(
                              text: '${Strings.authHaveAccount} ',
                              children: <InlineSpan>[
                                TextSpan(
                                  text: Strings.authLoginLink,
                                  style: AppTextStyles.titleSmall(
                                    color: c.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SafeArea(
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md.r),
                child: _SkipButton(onPressed: _finish),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A frosted pill over the photo.
class _SkipButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SkipButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.22),
      shape: const StadiumBorder(side: BorderSide(color: Color(0x55FFFFFF))),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md.w,
            vertical: AppSpacing.xs.h,
          ),
          child: Text(
            Strings.onboardingSkip,
            style: AppTextStyles.titleSmall(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// The current page stretches into a pill; the others stay dots.
class _Dots extends StatelessWidget {
  final int count;
  final int current;

  const _Dots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            margin: EdgeInsets.symmetric(horizontal: AppSpacing.xxs.w),
            width: i == current ? 28.w : 8.w,
            height: 8.h,
            decoration: BoxDecoration(
              color: i == current ? c.secondary : c.border,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
      ],
    );
  }
}
