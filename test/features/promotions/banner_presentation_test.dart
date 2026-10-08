import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/features/promotions/presentation/widgets/banner_media/banner_presentation.dart';

const double _frame = 16 / 9;

/// A [width] × [height] RGBA image, each pixel from [paint].
Uint8List _image(
  int width,
  int height,
  List<int> Function(int x, int y) paint,
) {
  final Uint8List rgba = Uint8List(width * height * 4);
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      rgba.setAll((y * width + x) * 4, paint(x, y));
    }
  }
  return rgba;
}

/// Every pixel a different shade, as in a photo.
List<int> _noise(int x, int y) => <int>[
  (x * 37 + y * 11) % 256,
  (x * 13 + y * 29) % 256,
  (x * 7 + y * 53) % 256,
  255,
];

const List<int> _white = <int>[255, 255, 255, 255];
const List<int> _clear = <int>[0, 0, 0, 0];
const List<int> _blue = <int>[20, 60, 160, 255];

BannerPresentation _present(
  int width,
  int height,
  List<int> Function(int x, int y) paint,
) => presentBanner(
  width: width,
  height: height,
  rgba: _image(width, height, paint),
  frameAspectRatio: _frame,
);

void main() {
  test('a landscape photo fills the frame', () {
    // 3:2 — like a storefront shot — loses under a sixth of its height.
    expect(_present(60, 40, _noise), const CoverPresentation());
  });

  test('a portrait photo is framed whole instead of cropped', () {
    expect(_present(30, 40, _noise), const FramedPresentation());
  });

  test('a square photo is too far from 16:9 to crop', () {
    expect(_present(40, 40, _noise), const FramedPresentation());
  });

  test('a logo on white is shown whole on that white', () {
    // A blue disc filling a white square, like a round logo.
    final BannerPresentation presentation = _present(
      40,
      40,
      (int x, int y) =>
          (x - 20) * (x - 20) + (y - 20) * (y - 20) < 18 * 18 ? _blue : _white,
    );

    expect(presentation, isA<IsolatedPresentation>());
    presentation as IsolatedPresentation;
    expect(presentation.backdrop, 0xFFFFFFFF);
    expect(presentation.aspectRatio, 1);
  });

  test("a product on a large white canvas is trimmed to the product", () {
    // The product covers only the middle of the canvas.
    final BannerPresentation presentation = _present(
      60,
      40,
      (int x, int y) => x >= 20 && x < 40 && y >= 10 && y < 30 ? _blue : _white,
    );

    final ContentRect content = (presentation as IsolatedPresentation).content;
    // A sample pixel of slack each way.
    expect(content.left, closeTo(19 / 60, 1e-9));
    expect(content.top, closeTo(9 / 40, 1e-9));
    expect(content.width, closeTo(22 / 60, 1e-9));
    expect(content.height, closeTo(22 / 40, 1e-9));
  });

  test('a cutout keeps its transparency, trimmed to the object', () {
    final BannerPresentation presentation = _present(
      40,
      40,
      (int x, int y) => x >= 10 && x < 30 && y >= 5 && y < 35 ? _blue : _clear,
    );

    presentation as IsolatedPresentation;
    expect(presentation.backdrop, isNull);
    expect(
      presentation.content,
      const ContentRect(9 / 40, 4 / 40, 22 / 40, 32 / 40),
    );
  });

  test('one corner unlike the others makes it a photo', () {
    // A white wall with a door in the bottom-left corner.
    final BannerPresentation presentation = _present(
      60,
      40,
      (int x, int y) => x < 8 && y > 30 ? <int>[230, 160, 90, 255] : _white,
    );

    expect(presentation, const CoverPresentation());
  });

  test('JPEG noise on a flat background still counts as flat', () {
    final BannerPresentation presentation = _present(
      40,
      40,
      (int x, int y) => <int>[250 - (x + y) % 9, 252, 248 - (x * y) % 7, 255],
    );

    expect(presentation, isA<IsolatedPresentation>());
  });
}
