// TEMPORARY visual-validation harness — renders the real FeaturedSliderWidget
// with real banner files and writes PNGs. Not part of the suite; deleted
// after review.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/config/locale/app_localizations.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/core/theme/app_theme.dart';
import 'package:ssm/features/promotions/domain/entities/store_promotion.dart';
import 'package:ssm/features/promotions/domain/repos/promotions_repository.dart';
import 'package:ssm/features/promotions/presentation/cubit/promotions_cubit.dart';
import 'package:ssm/features/promotions/presentation/widgets/featured_slider_widget.dart';
import 'package:ssm/injection_container.dart';

import 'helpers/fake_zone_repository.dart';

const String _dir =
    r'C:\Users\Admin\AppData\Local\Temp\claude\d--project-ssm\95de532d-2423-4c38-9a5b-965f32086b03\scratchpad\banners';

class _Repo implements PromotionsRepository {
  final List<StorePromotion> promotions;
  _Repo(this.promotions);
  @override
  Future<Either<Failure, List<StorePromotion>>> getFeaturedPromotions({
    int page = 1,
    int limit = featuredPromotionsLimit,
  }) async => Right(promotions);
}

class _Arabic extends AppLocalizations {
  final Map<String, String> strings;
  _Arabic(this.strings) : super(const Locale('ar'));
  @override
  String text(String key) => strings[key] ?? key;
}

Future<void> _loadFonts() async {
  final FontLoader cairo = FontLoader('Cairo');
  for (final String w in <String>['Regular', 'Medium', 'SemiBold', 'Bold']) {
    cairo.addFont(
      Future<ByteData>.value(
        ByteData.sublistView(File('assets/fonts/Cairo-$w.ttf').readAsBytesSync()),
      ),
    );
  }
  await cairo.load();
  final String root = Platform.environment['FLUTTER_ROOT']!;
  final FontLoader icons = FontLoader('MaterialIcons')
    ..addFont(
      Future<ByteData>.value(
        ByteData.sublistView(
          File(
            '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
          ).readAsBytesSync(),
        ),
      ),
    );
  await icons.load();
}

StorePromotion _promo(int id, String name, String file) => StorePromotion(
  id: id,
  storeId: id,
  storeName: name,
  bannerUrl: 'https://x/$file',
);

void main() {
  setUpAll(() async {
    final Map<String, dynamic> ar =
        jsonDecode(File('lang/ar.json').readAsStringSync())
            as Map<String, dynamic>;
    if (ServiceLocator.instance.isRegistered<AppLocalizations>()) {
      ServiceLocator.instance.unregister<AppLocalizations>();
    }
    ServiceLocator.injectAppLocalizations(
      _Arabic(ar.map((String k, dynamic v) => MapEntry(k, v.toString()))),
    );
    await _loadFonts();
  });

  Future<void> render(
    WidgetTester tester,
    String name,
    List<StorePromotion> promotions, {
    double width = 390,
  }) async {
    final Size screen = Size(width, 520);
    tester.view.physicalSize = screen * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final GlobalKey boundary = GlobalKey();
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: appTheme,
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: Colors.white,
              body: RepaintBoundary(
                key: boundary,
                child: ColoredBox(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                    child: BlocProvider<PromotionsCubit>(
                      create: (_) => PromotionsCubit(
                        promotionsRepository: _Repo(promotions),
                        zoneRepository: FakeZoneRepository(),
                      )..load(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          FeaturedSliderWidget(
                            bannerImage: (String url) =>
                                FileImage(File('$_dir\\${url.split('/').last}')),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    // Each image load step (read, buffer, codec, frame) needs real time and
    // then a pump to deliver it.
    for (int i = 0; i < 40; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pump();
    }
    await tester.runAsync(() async {
      final RenderRepaintBoundary box =
          boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final ui.Image image = await box.toImage(pixelRatio: 2);
      final ByteData? png = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      File('$_dir\\render_$name.png').writeAsBytesSync(
        png!.buffer.asUint8List(),
      );
    });
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  }

  final StorePromotion pharmacy = _promo(5, 'SSM Cairo Pharmacy', 'p5_mobile.jpg');
  final StorePromotion logo = _promo(4, 'Hussein', 'p4_mobile.jpeg');
  final StorePromotion portrait = _promo(2, 'صيدلية الشفاء', 'syn_portrait.jpg');
  final StorePromotion margins = _promo(6, 'متجر المنتجات', 'syn_margins.jpg');
  final StorePromotion cutout = _promo(7, 'متجر شفاف', 'syn_cutout.png');

  testWidgets('pharmacy', (WidgetTester t) => render(t, 'pharmacy', <StorePromotion>[pharmacy]));
  testWidgets('logo', (WidgetTester t) => render(t, 'logo', <StorePromotion>[logo]));
  testWidgets('portrait', (WidgetTester t) => render(t, 'portrait', <StorePromotion>[portrait]));
  testWidgets('margins', (WidgetTester t) => render(t, 'margins', <StorePromotion>[margins]));
  testWidgets('cutout', (WidgetTester t) => render(t, 'cutout', <StorePromotion>[cutout]));
  testWidgets('carousel', (WidgetTester t) => render(t, 'carousel', <StorePromotion>[pharmacy, logo, portrait]));
  testWidgets('narrow 320', (WidgetTester t) => render(t, 'w320', <StorePromotion>[pharmacy, logo], width: 320));
  testWidgets('wide 430', (WidgetTester t) => render(t, 'w430', <StorePromotion>[logo, pharmacy], width: 430));
}
