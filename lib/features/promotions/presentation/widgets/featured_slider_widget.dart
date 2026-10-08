import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../domain/entities/store_promotion.dart';
import '../cubit/promotions_cubit.dart';
import '../cubit/promotions_state.dart';
import 'banner_media/banner_media.dart';

/// Home's auto-playing carousel of featured store banners. Expects a
/// [PromotionsCubit] above it.
///
/// Collapses to nothing — [bottomSpacing] included — when the zone has no
/// promotions or they can't be fetched: banners are optional, and the
/// catalog below reports its own errors.
class FeaturedSliderWidget extends StatelessWidget {
  /// The gap to the next Home section, kept only while something shows.
  final double bottomSpacing;

  /// Loads a banner by URL — from the network and its disk cache, unless a
  /// test supplies the images.
  final BannerImageBuilder bannerImage;

  const FeaturedSliderWidget({
    super.key,
    this.bottomSpacing = 0,
    this.bannerImage = _networkBanner,
  });

  static ImageProvider _networkBanner(String url) =>
      CachedNetworkImageProvider(url);

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
            bannerImage: bannerImage,
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

typedef BannerImageBuilder = ImageProvider Function(String url);

/// Shared by the carousel and its shimmer, so loading doesn't jump.
///
/// A card is a full-width image over a strip with the store's name and the
/// call to action. Every slide has the same frame, whatever each upload's
/// shape: [BannerMedia] adapts how each image fills it.
abstract class _SliderLayout {
  /// Landscape, like the storefront photos admins mostly upload.
  static const double mediaAspectRatio = 16 / 9;

  /// Caps the image on wide screens, where 16:9 would make the card tower;
  /// the frame just gets wider there.
  static const double maxMediaHeight = 240;

  /// Lets the neighbouring card peek in, hinting the row swipes.
  static const double viewportFraction = 0.92;

  static double get pageGap => AppSpacing.xs.w;

  /// Holds the eyebrow and title at up to [maxTextScale]. In `sp`, like the
  /// text: `r` also shrinks with a screen shorter than the design, which
  /// the text doesn't.
  static double get detailsHeight => 76.sp;

  /// The details strip has a fixed height, so very large text is capped
  /// rather than overflowing it.
  static const double maxTextScale = 1.2;

  static double get dotsGap => AppSpacing.md.h;
  static double get dotSize => 6.r;

  static double cardWidth(double maxWidth) =>
      maxWidth * viewportFraction - pageGap;

  static double mediaHeight(double maxWidth) =>
      math.min(cardWidth(maxWidth) / mediaAspectRatio, maxMediaHeight);

  static double cardHeight(double maxWidth) =>
      mediaHeight(maxWidth) + detailsHeight;

  static BorderRadius get cardRadius => BorderRadius.circular(AppRadius.xl.r);
}

class _PromotionsCarousel extends StatefulWidget {
  final List<StorePromotion> promotions;
  final BannerImageBuilder bannerImage;

  const _PromotionsCarousel({
    super.key,
    required this.promotions,
    required this.bannerImage,
  });

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
        final double mediaHeight = _SliderLayout.mediaHeight(
          constraints.maxWidth,
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: _SliderLayout.cardHeight(constraints.maxWidth),
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
                    child: _PromotionCard(
                      promotion: widget.promotions[page % _count],
                      mediaHeight: mediaHeight,
                      bannerImage: widget.bannerImage,
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

/// One featured store: its banner across the top, its name and a call to
/// action beneath, on a soft brand tint. The whole card opens the store.
class _PromotionCard extends StatelessWidget {
  final StorePromotion promotion;
  final double mediaHeight;
  final BannerImageBuilder bannerImage;

  const _PromotionCard({
    required this.promotion,
    required this.mediaHeight,
    required this.bannerImage,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
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
        child: ClipRRect(
          borderRadius: _SliderLayout.cardRadius,
          child: ColoredBox(
            color: c.primary.withValues(alpha: 0.08),
            child: Column(
              children: <Widget>[
                // Clipped: a blurred backdrop paints past its bounds, into
                // the strip below.
                SizedBox(
                  height: mediaHeight,
                  width: double.infinity,
                  child: ClipRect(
                    child: _CardMedia(
                      promotion: promotion,
                      bannerImage: bannerImage,
                    ),
                  ),
                ),
                Expanded(
                  child: MediaQuery.withClampedTextScaling(
                    maxScaleFactor: _SliderLayout.maxTextScale,
                    child: _CardDetails(storeName: promotion.storeName),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The banner, presented to suit the image (see [BannerMedia]), with the
/// video badge over it.
class _CardMedia extends StatelessWidget {
  final StorePromotion promotion;
  final BannerImageBuilder bannerImage;

  const _CardMedia({required this.promotion, required this.bannerImage});

  @override
  Widget build(BuildContext context) {
    final String? bannerUrl = promotion.bannerUrl;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (bannerUrl == null)
            const _BannerFallback()
          else
            BannerMedia(
              image: bannerImage(bannerUrl),
              // The frame's real shape: wider than 16:9 where the height
              // is capped.
              frameAspectRatio: constraints.maxWidth / constraints.maxHeight,
              placeholder: const _ShimmerBox(),
              fallback: const _BannerFallback(),
            ),
          if (promotion.hasVideo)
            PositionedDirectional(
              top: AppSpacing.sm.r,
              end: AppSpacing.sm.r,
              child: const _VideoBadge(),
            ),
        ],
      ),
    );
  }
}

/// The strip under the banner: an eyebrow and the store's name, with the
/// call to action at the end.
class _CardDetails extends StatelessWidget {
  final String? storeName;

  const _CardDetails({required this.storeName});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final String? storeName = this.storeName;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md.r,
        vertical: AppSpacing.sm.sp,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Without a name the title already says it's a featured
                // store.
                if (storeName != null)
                  Text(
                    Strings.featuredStore,
                    style: AppTextStyles.label(color: c.primary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  storeName ?? Strings.featuredStore,
                  style: AppTextStyles.title(color: c.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.sm.r),
          const _CtaPill(),
        ],
      ),
    );
  }
}

/// Looks like a button, but the whole card is the tap target.
class _CtaPill extends StatelessWidget {
  const _CtaPill();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.primary,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md.r,
          vertical: AppSpacing.xs.r,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              Strings.featuredStoreCta,
              style: AppTextStyles.titleSmall(color: Colors.white),
              maxLines: 1,
            ),
            SizedBox(width: AppSpacing.xxs.r),
            // Mirrors in RTL, pointing the way the text reads.
            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16.r),
          ],
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

/// No banner, or it failed to load: a storefront on the brand tint — the
/// store's name is right below it.
class _BannerFallback extends StatelessWidget {
  const _BannerFallback();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return ColoredBox(
      color: c.primary.withValues(alpha: 0.12),
      child: Center(
        child: Icon(Icons.storefront_outlined, color: c.primary, size: 48.r),
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
              color: i == current
                  ? c.primary
                  : c.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
      ],
    );
  }
}

/// The carousel's first frame: the same card box, and room for the dots.
class _SliderShimmer extends StatelessWidget {
  const _SliderShimmer();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: _SliderLayout.cardWidth(constraints.maxWidth),
            height: _SliderLayout.cardHeight(constraints.maxWidth),
            child: _ShimmerBox(radius: _SliderLayout.cardRadius),
          ),
          SizedBox(height: _SliderLayout.dotsGap + _SliderLayout.dotSize),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  /// Null fills the parent's own clip (the card's).
  final BorderRadius? radius;

  const _ShimmerBox({this.radius});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: DecoratedBox(
        decoration: BoxDecoration(color: Colors.white, borderRadius: radius),
        child: const SizedBox.expand(),
      ),
    );
  }
}
