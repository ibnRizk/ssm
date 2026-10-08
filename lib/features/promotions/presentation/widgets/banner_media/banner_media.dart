import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../../core/utils/extension.dart';
import 'banner_presentation.dart';

/// A banner image filling a frame of [frameAspectRatio], drawn the way
/// [presentBanner] picks for it: a photo cropped to fill, a photo of
/// another shape framed whole over a blur of itself, or a logo or product
/// shown whole on its own background. Fills its parent, which should have
/// the frame's shape.
class BannerMedia extends StatefulWidget {
  final ImageProvider image;
  final double frameAspectRatio;

  /// While the image loads.
  final Widget placeholder;

  /// When it can't be loaded.
  final Widget fallback;

  const BannerMedia({
    super.key,
    required this.image,
    required this.frameAspectRatio,
    required this.placeholder,
    required this.fallback,
  });

  @override
  State<BannerMedia> createState() => _BannerMediaState();
}

class _BannerMediaState extends State<BannerMedia> {
  late Future<BannerPresentation> _presentation;

  @override
  void initState() {
    super.initState();
    _presentation = _BannerPresentations.of(
      widget.image,
      widget.frameAspectRatio,
    );
  }

  @override
  void didUpdateWidget(BannerMedia oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image ||
        oldWidget.frameAspectRatio != widget.frameAspectRatio) {
      _presentation = _BannerPresentations.of(
        widget.image,
        widget.frameAspectRatio,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BannerPresentation>(
      future: _presentation,
      builder: (BuildContext context, AsyncSnapshot<BannerPresentation> s) {
        if (s.hasError) return widget.fallback;
        final BannerPresentation? presentation = s.data;
        if (presentation == null) return widget.placeholder;
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // Decoded at the size it's shown, not the upload's.
            final ImageProvider image = ResizeImage.resizeIfNeeded(
              constraints.maxWidth.cacheSize(context),
              null,
              widget.image,
            );
            Widget picture(BoxFit fit) => Image(
              image: image,
              fit: fit,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => widget.fallback,
            );
            return switch (presentation) {
              CoverPresentation() => picture(BoxFit.cover),
              FramedPresentation(:final double zoom) => ClipRect(
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    _BlurredBackdrop(image: widget.image),
                    // Enlarged about the centre, so a moderate portrait
                    // loses its top and bottom edges evenly.
                    Transform.scale(
                      scale: zoom,
                      child: picture(BoxFit.contain),
                    ),
                  ],
                ),
              ),
              IsolatedPresentation(
                :final int? backdrop,
                :final ContentRect content,
                :final double aspectRatio,
              ) =>
                ColoredBox(
                  color: backdrop == null
                      ? Colors.transparent
                      : Color(backdrop),
                  child: Padding(
                    // Breathing room, so the art doesn't touch the frame.
                    padding: EdgeInsets.all(
                      constraints.biggest.shortestSide * 0.08,
                    ),
                    child: _TrimmedImage(
                      image: image,
                      content: content,
                      aspectRatio: aspectRatio,
                      fallback: widget.fallback,
                    ),
                  ),
                ),
            };
          },
        );
      },
    );
  }
}

/// A photo's own colours, softened, behind it where it doesn't reach.
class _BlurredBackdrop extends StatelessWidget {
  final ImageProvider image;

  const _BlurredBackdrop({required this.image});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        ImageFiltered(
          imageFilter: ui.ImageFilter.blur(
            sigmaX: 18,
            sigmaY: 18,
            tileMode: TileMode.clamp,
          ),
          // A tiny decode is enough for a blur.
          child: Image(
            image: ResizeImage(image, width: _BannerPresentations.sampleWidth),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        // Pushes the blur back, so the sharp photo reads as the subject.
        ColoredBox(color: Colors.black.withValues(alpha: 0.12)),
      ],
    );
  }
}

/// The [content] part of an image as large as fits, centred: its margins
/// fall outside the box and are clipped. Drawn at the image's own aspect
/// ratio, so never distorted.
class _TrimmedImage extends StatelessWidget {
  final ImageProvider image;
  final ContentRect content;
  final double aspectRatio;
  final Widget fallback;

  const _TrimmedImage({
    required this.image,
    required this.content,
    required this.aspectRatio,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // In units of the image's height: it's aspectRatio × 1.
        final double contentWidth = content.width * aspectRatio;
        final double contentHeight = content.height;
        final double scale =
            (constraints.maxWidth / contentWidth) <
                (constraints.maxHeight / contentHeight)
            ? constraints.maxWidth / contentWidth
            : constraints.maxHeight / contentHeight;
        final double imageWidth = aspectRatio * scale;
        final double imageHeight = scale;
        return ClipRect(
          child: Stack(
            children: <Widget>[
              Positioned(
                left:
                    constraints.maxWidth / 2 -
                    (content.left + content.width / 2) * imageWidth,
                top:
                    constraints.maxHeight / 2 -
                    (content.top + content.height / 2) * imageHeight,
                width: imageWidth,
                height: imageHeight,
                child: Image(
                  image: image,
                  fit: BoxFit.fill,
                  gaplessPlayback: true,
                  errorBuilder: (_, __, ___) => fallback,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Each image is sampled once — the carousel rebuilds its pages as they
/// scroll, and every lap would otherwise decode the sample again.
abstract class _BannerPresentations {
  /// The sample's width: enough to find corners and content bounds.
  static const int sampleWidth = 64;

  /// Enough for a page of promotions, without holding on to every image
  /// the app has ever shown.
  static const int _capacity = 24;

  static final LinkedHashMap<
    (ImageProvider, double),
    Future<BannerPresentation>
  >
  _cache = LinkedHashMap<(ImageProvider, double), Future<BannerPresentation>>();

  static Future<BannerPresentation> of(
    ImageProvider image,
    double frameAspectRatio,
  ) {
    final (ImageProvider, double) key = (image, frameAspectRatio);
    final Future<BannerPresentation>? cached = _cache.remove(key);
    if (cached != null) return _cache[key] = cached;
    if (_cache.length >= _capacity) _cache.remove(_cache.keys.first);
    final Future<BannerPresentation> presentation = _sample(
      image,
      frameAspectRatio,
    );
    // A failure isn't kept: the next time the banner shows, it retries.
    presentation.catchError((Object _) {
      _cache.remove(key);
      return const CoverPresentation();
    });
    return _cache[key] = presentation;
  }

  static Future<BannerPresentation> _sample(
    ImageProvider image,
    double frameAspectRatio,
  ) async {
    final ui.Image sample = await _decode(
      ResizeImage(image, width: sampleWidth),
    );
    try {
      final ByteData? bytes = await sample.toByteData(
        format: ui.ImageByteFormat.rawStraightRgba,
      );
      if (bytes == null) throw StateError('The sample has no pixels.');
      return presentBanner(
        width: sample.width,
        height: sample.height,
        rgba: bytes.buffer.asUint8List(),
        frameAspectRatio: frameAspectRatio,
      );
    } finally {
      sample.dispose();
    }
  }

  static Future<ui.Image> _decode(ImageProvider image) {
    final Completer<ui.Image> decoded = Completer<ui.Image>();
    final ImageStream stream = image.resolve(ImageConfiguration.empty);
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool _) {
        stream.removeListener(listener);
        if (!decoded.isCompleted) decoded.complete(info.image.clone());
        info.dispose();
      },
      onError: (Object error, StackTrace? stackTrace) {
        stream.removeListener(listener);
        if (!decoded.isCompleted) decoded.completeError(error, stackTrace);
      },
    );
    stream.addListener(listener);
    return decoded.future;
  }
}
