import 'dart:math' as math;
import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// How a banner image is drawn in its frame. Admins upload anything from
/// storefront photos to logos on white, in any shape, so it's chosen per
/// image by [presentBanner] rather than one fit for all.
sealed class BannerPresentation extends Equatable {
  const BannerPresentation();

  @override
  List<Object?> get props => [];
}

/// A photo close to the frame's shape: fills it, losing at most
/// [maxCoverCrop] of one side.
final class CoverPresentation extends BannerPresentation {
  const CoverPresentation();
}

/// A photo too tall or too wide to crop that much: shown whole, over a
/// blurred copy of itself instead of empty bands.
final class FramedPresentation extends BannerPresentation {
  const FramedPresentation();
}

/// Art on a flat or transparent background — a logo, a product: shown whole,
/// trimmed to its [content], on its own background colour so the margins
/// in the file blend into the frame.
final class IsolatedPresentation extends BannerPresentation {
  /// The background, as opaque ARGB; null when it's transparent.
  final int? backdrop;

  /// The part of the image that isn't background.
  final ContentRect content;

  /// The whole image's width over its height.
  final double aspectRatio;

  const IsolatedPresentation({
    required this.backdrop,
    required this.content,
    required this.aspectRatio,
  });

  @override
  List<Object?> get props => [backdrop, content, aspectRatio];
}

/// A rectangle as fractions of the image's width and height.
class ContentRect extends Equatable {
  final double left;
  final double top;
  final double width;
  final double height;

  const ContentRect(this.left, this.top, this.width, this.height);

  static const ContentRect full = ContentRect(0, 0, 1, 1);

  @override
  List<Object?> get props => [left, top, width, height];
}

/// The most of one side a photo may lose to fill the frame. Past it — a
/// portrait photo in a landscape frame — it's framed whole instead.
const double maxCoverCrop = 0.3;

/// Each corner patch, as a share of the image's shorter side.
const double _cornerShare = 0.12;

/// Below this alpha a pixel counts as transparent.
const int _clearAlpha = 24;

/// How far a channel may stray from the background and still be it —
/// enough for JPEG noise on a flat white.
const int _tolerance = 28;

/// The share of each corner patch that must match for a flat background.
const double _flatShare = 0.9;

/// The share of the corners that must be clear for a transparent one.
const double _clearShare = 0.75;

/// Picks how to draw an image of [width] × [height] in a frame of
/// [frameAspectRatio], from [rgba] — its pixels, straight RGBA, row by row.
/// A small sample is plenty: only the corners and the content's bounds are
/// read.
///
/// A background is flat when every corner matches the same colour; a photo
/// rarely does, a logo or product shot almost always does.
BannerPresentation presentBanner({
  required int width,
  required int height,
  required Uint8List rgba,
  required double frameAspectRatio,
}) {
  final double aspectRatio = width / height;
  final int patch = math.max(
    1,
    (math.min(width, height) * _cornerShare).round(),
  );
  final List<(int, int)> corners = <(int, int)>[
    (0, 0),
    (width - patch, 0),
    (0, height - patch),
    (width - patch, height - patch),
  ];
  int alphaAt(int x, int y) => rgba[(y * width + x) * 4 + 3];

  int total = 0;
  int clear = 0;
  int r = 0;
  int g = 0;
  int b = 0;
  for (final (int cx, int cy) in corners) {
    for (int y = cy; y < cy + patch; y++) {
      for (int x = cx; x < cx + patch; x++) {
        total++;
        final int i = (y * width + x) * 4;
        if (rgba[i + 3] < _clearAlpha) {
          clear++;
        } else {
          r += rgba[i];
          g += rgba[i + 1];
          b += rgba[i + 2];
        }
      }
    }
  }

  if (clear >= total * _clearShare) {
    return IsolatedPresentation(
      backdrop: null,
      content: _contentRect(
        width,
        height,
        (int x, int y) => alphaAt(x, y) >= _clearAlpha,
      ),
      aspectRatio: aspectRatio,
    );
  }

  final int opaque = total - clear;
  final (int, int, int) mean = (r ~/ opaque, g ~/ opaque, b ~/ opaque);
  bool isBackground(int x, int y) {
    final int i = (y * width + x) * 4;
    return rgba[i + 3] < _clearAlpha ||
        ((rgba[i] - mean.$1).abs() <= _tolerance &&
            (rgba[i + 1] - mean.$2).abs() <= _tolerance &&
            (rgba[i + 2] - mean.$3).abs() <= _tolerance);
  }

  // Every corner on its own, so one odd corner (a door, a shadow) is
  // enough to make it a photo.
  final bool flat = corners.every(((int, int) corner) {
    int matching = 0;
    for (int y = corner.$2; y < corner.$2 + patch; y++) {
      for (int x = corner.$1; x < corner.$1 + patch; x++) {
        if (isBackground(x, y)) matching++;
      }
    }
    return matching >= patch * patch * _flatShare;
  });

  if (flat) {
    return IsolatedPresentation(
      backdrop: 0xFF000000 | (mean.$1 << 16) | (mean.$2 << 8) | mean.$3,
      content: _contentRect(
        width,
        height,
        (int x, int y) => !isBackground(x, y),
      ),
      aspectRatio: aspectRatio,
    );
  }

  final double crop =
      1 -
      math.min(aspectRatio, frameAspectRatio) /
          math.max(aspectRatio, frameAspectRatio);
  return crop <= maxCoverCrop
      ? const CoverPresentation()
      : const FramedPresentation();
}

/// The bounds of the pixels [isContent] accepts, a pixel wider each way
/// for the sample's coarseness; the whole image when there are none.
ContentRect _contentRect(
  int width,
  int height,
  bool Function(int x, int y) isContent,
) {
  int minX = width;
  int minY = height;
  int maxX = -1;
  int maxY = -1;
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      if (!isContent(x, y)) continue;
      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
    }
  }
  if (maxX < 0) return ContentRect.full;
  minX = math.max(0, minX - 1);
  minY = math.max(0, minY - 1);
  maxX = math.min(width - 1, maxX + 1);
  maxY = math.min(height - 1, maxY + 1);
  return ContentRect(
    minX / width,
    minY / height,
    (maxX - minX + 1) / width,
    (maxY - minY + 1) / height,
  );
}
