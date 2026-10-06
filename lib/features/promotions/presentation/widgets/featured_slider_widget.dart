import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extension.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../domain/entities/store_promotion.dart';
import '../cubit/promotions_cubit.dart';
import '../cubit/promotions_state.dart';

/// Home's auto-playing carousel of featured store banners. Expects a
/// [PromotionsCubit] above it.
///
/// Collapses to nothing — [bottomSpacing] included — when the zone has no
/// promotions or they can't be fetched: banners are optional, and the
/// catalog below reports its own errors.
class FeaturedSliderWidget extends StatelessWidget {
  /// The gap to the next Home section, kept only while something shows.
  final double bottomSpacing;

  const FeaturedSliderWidget({super.key, this.bottomSpacing = 0});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PromotionsCubit, PromotionsState>(
      builder: (BuildContext context, PromotionsState state) {
        final Widget? content = switch (state) {
          PromotionsInitial() || PromotionsLoading() => const _SliderShimmer(),
          // Keyed by the list: new promotions restart the carousel from the
          // first banner rather than an index that may no longer exist.
          PromotionsLoaded(:final promotions) => _PromotionsCarousel(
            key: ObjectKey(promotions),
            promotions: promotions,
          ),
          PromotionsEmpty() || PromotionsError() => null,
        };
        if (content == null) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(bottom: bottomSpacing),
          child: content,
        );
      },
    );
  }
}

/// Shared by the carousel and its shimmer, so loading doesn't jump.
abstract class _SliderLayout {
  /// The backend's phone banner is 1080 × 1350.
  static const double bannerAspectRatio = 4 / 5;

  /// Lets the neighbouring banners peek in, hinting the row swipes.
  static const double viewportFraction = 0.86;

  static double get pageGap => AppSpacing.xs.w;
  static double get dotsGap => AppSpacing.sm.h;
  static double get dotSize => 6.r;

  static double bannerWidth(double maxWidth) =>
      maxWidth * viewportFraction - pageGap;

  static double bannerHeight(double maxWidth) =>
      bannerWidth(maxWidth) / bannerAspectRatio;

  static BorderRadius get radius => BorderRadius.circular(AppRadius.xl.r);
}

class _PromotionsCarousel extends StatefulWidget {
  final List<StorePromotion> promotions;

  const _PromotionsCarousel({super.key, required this.promotions});

  @override
  State<_PromotionsCarousel> createState() => _PromotionsCarouselState();
}

class _PromotionsCarouselState extends State<_PromotionsCarousel> {
  static const Duration _interval = Duration(seconds: 5);
  static const Duration _slide = Duration(milliseconds: 550);

  late final PageController _controller;

  /// The banner in view, for the dots — kept out of `setState` so a page
  /// change doesn't rebuild the pages.
  final ValueNotifier<int> _current = ValueNotifier<int>(0);

  Timer? _timer;
  bool _autoPlayAllowed = false;
  bool _dragging = false;

  int get _count => widget.promotions.length;

  /// With several banners the pages are unbounded and indexed modulo the
  /// count, starting far from 0, so the carousel wraps both ways.
  bool get _loops => _count > 1;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      viewportFraction: _SliderLayout.viewportFraction,
      initialPage: _loops ? _count * 1000 : 0,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Paused while Home is an inactive tab (its ticker mode is off) and for
    // customers who asked the OS to reduce motion.
    final bool allowed =
        _loops &&
        TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context);
    if (allowed != _autoPlayAllowed) {
      _autoPlayAllowed = allowed;
      _restartTimer();
    }
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = _autoPlayAllowed && !_dragging
        ? Timer.periodic(_interval, (_) => _advance())
        : null;
  }

  void _advance() {
    if (!_controller.hasClients) return;
    _controller.nextPage(duration: _slide, curve: Curves.easeInOutCubic);
  }

  /// A swipe pauses auto-play; it resumes a full interval after the swipe.
  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _dragging = true;
      _restartTimer();
    } else if (notification is ScrollEndNotification && _dragging) {
      _dragging = false;
      _restartTimer();
    }
    return false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _current.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = _SliderLayout.bannerWidth(constraints.maxWidth);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: _SliderLayout.bannerHeight(constraints.maxWidth),
              child: NotificationListener<ScrollNotification>(
                onNotification: _onScroll,
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _loops ? null : _count,
                  onPageChanged: (int page) => _current.value = page % _count,
                  itemBuilder: (BuildContext context, int page) => Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _SliderLayout.pageGap / 2,
                    ),
                    child: _PromotionBanner(
                      promotion: widget.promotions[page % _count],
                      width: width,
                    ),
                  ),
                ),
              ),
            ),
            if (_loops) ...<Widget>[
              SizedBox(height: _SliderLayout.dotsGap),
              ValueListenableBuilder<int>(
                valueListenable: _current,
                builder: (_, int current, __) =>
                    _PageDots(count: _count, current: current),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// One banner, shown whole: letterboxed, never cropped — admins put text and
/// phone numbers on them. Opens the store by id.
class _PromotionBanner extends StatelessWidget {
  final StorePromotion promotion;
  final double width;

  const _PromotionBanner({required this.promotion, required this.width});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final String? bannerUrl = promotion.bannerUrl;
    final Widget fallback = _BannerFallback(storeName: promotion.storeName);
    return Semantics(
      button: true,
      label: <String>[
        promotion.storeName ?? Strings.featuredStore,
        if (promotion.hasVideo) Strings.featuredStoreVideo,
      ].join(', '),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () =>
            context.push(AppRoutes.storeDetailsPath(promotion.storeId)),
        child: DecoratedBox(
          decoration: AppDecorations.card(c, radius: AppRadius.xl),
          child: ClipRRect(
            borderRadius: _SliderLayout.radius,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                if (bannerUrl == null)
                  fallback
                else
                  CachedNetworkImage(
                    imageUrl: bannerUrl,
                    fit: BoxFit.contain,
                    memCacheWidth: width.cacheSize(context),
                    fadeInDuration: const Duration(milliseconds: 250),
                    placeholder: (_, __) => const _ShimmerBox(),
                    errorWidget: (_, __, ___) => fallback,
                  ),
                if (promotion.hasVideo)
                  PositionedDirectional(
                    top: AppSpacing.sm.r,
                    end: AppSpacing.sm.r,
                    child: const _VideoBadge(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Marks a store that has a video; the video itself plays on the store page.
class _VideoBadge extends StatelessWidget {
  const _VideoBadge();

  @override
  Widget build(BuildContext context) {
    final double size = 32.r;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.55),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.85),
          width: 1.5,
        ),
      ),
      child: Icon(
        Icons.play_arrow_rounded,
        color: Colors.white,
        size: size * 0.62,
      ),
    );
  }
}

/// No banner, or it failed to load: the store's name on the brand colour.
class _BannerFallback extends StatelessWidget {
  final String? storeName;

  const _BannerFallback({required this.storeName});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final String? storeName = this.storeName;
    return ColoredBox(
      color: c.primary,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg.r),
          child: storeName == null
              ? Icon(
                  Icons.storefront_outlined,
                  color: Colors.white.withValues(alpha: 0.85),
                  size: 48.r,
                )
              : Text(
                  storeName,
                  style: AppTextStyles.h2(color: Colors.white),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  final int count;
  final int current;

  const _PageDots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final double size = _SliderLayout.dotSize;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            margin: EdgeInsets.symmetric(horizontal: size / 3),
            width: i == current ? size * 3 : size,
            height: size,
            decoration: BoxDecoration(
              color: i == current ? c.primary : c.border,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
      ],
    );
  }
}

/// The carousel's first frame: the same banner box, and room for the dots.
class _SliderShimmer extends StatelessWidget {
  const _SliderShimmer();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: _SliderLayout.bannerWidth(constraints.maxWidth),
            height: _SliderLayout.bannerHeight(constraints.maxWidth),
            child: const _ShimmerBox(),
          ),
          SizedBox(height: _SliderLayout.dotsGap + _SliderLayout.dotSize),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: _SliderLayout.radius,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
