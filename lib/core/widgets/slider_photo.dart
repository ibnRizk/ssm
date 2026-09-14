import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '/core/utils/enums.dart';
import '/core/utils/extension.dart';
import '../../config/locale/app_localizations.dart';
import '../../injection_container.dart';

class SliderPhotoScreen extends StatelessWidget {
  final List images;
  final List<File>? imagesFiles;
  final ImgPath path;
  final int imageIndex;
  const SliderPhotoScreen({
    super.key,
    required this.images,
    this.imagesFiles,
    required this.imageIndex,
    required this.path,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.text('imagePreview')),
        elevation: 4,
      ),
      body: Container(
        color: colors.background,
        child: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: imagesFiles != null
                  ? Image.file(imagesFiles![index]).image
                  : CachedNetworkImageProvider(getPath(index)),
              initialScale: PhotoViewComputedScale.contained * 0.8,
              heroAttributes: PhotoViewHeroAttributes(
                tag: imagesFiles != null
                    ? imagesFiles![index].path
                    : path == ImgPath.noKey
                    ? index
                    : images[index].id,
              ),
            );
          },
          itemCount: imagesFiles != null ? imagesFiles!.length : images.length,
          loadingBuilder: (context, event) => Center(
            child: CircularProgressIndicator(
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded /
                        (event.expectedTotalBytes ?? 1),
            ).appLoading,
          ),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          pageController: PageController(initialPage: imageIndex),
          onPageChanged: (v) {},
        ),
      ),
    );
  }

  getPath(index) {
    switch (path) {
      case ImgPath.file:
        return images[index].file;
      case ImgPath.mediaPath:
        return images[index].mediaPath;
      case ImgPath.noKey:
        return images[index];
    }
  }
}
