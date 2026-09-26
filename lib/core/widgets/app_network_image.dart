import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/extension.dart';

/// A cached remote image clipped to [borderRadius]. Shows [fallback] while
/// there's no [url], while it loads, and when it fails — so a missing or
/// broken image never leaves a hole in the layout.
class AppNetworkImage extends StatelessWidget {
  final String? url;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final Widget fallback;

  const AppNetworkImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    required this.fallback,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    final String? url = this.url;
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: url == null
            ? fallback
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                memCacheWidth: width.cacheSize(context),
                placeholder: (_, __) => fallback,
                errorWidget: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}
