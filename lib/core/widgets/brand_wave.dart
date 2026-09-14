import 'package:flutter/material.dart';

/// The soft orange wave that bleeds off the bottom edge of hero/promo cards
/// — the subscription banner on Home, and the same motif on the splash and
/// parcel-arrival screens. Give it a bounded box (e.g. a `Positioned` with an
/// explicit `height`) inside a `ClipRRect`/`ClipPath` so it's clipped to the
/// card's corners instead of its own straight edges.
class BrandWave extends StatelessWidget {
  final Color color;

  const BrandWave({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WavePainter(color),
      child: const SizedBox.expand(),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;

  const _WavePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    final Path path = Path()
      ..moveTo(0, size.height * 0.55)
      ..quadraticBezierTo(
        size.width * 0.18,
        size.height * 0.05,
        size.width * 0.5,
        size.height * 0.28,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.48,
        size.width,
        size.height * 0.18,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.color != color;
}
