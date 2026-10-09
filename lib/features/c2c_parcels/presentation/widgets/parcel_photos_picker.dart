import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/dashed_border_box.dart';
import '../../domain/entities/c2c_parcel_draft.dart';

/// Thumbnails of the picked parcel photos, each removable, followed by an
/// "add" tile while fewer than five are picked.
class ParcelPhotosPicker extends StatelessWidget {
  final List<C2cParcelPhoto> photos;
  final bool picking;
  final ValueChanged<C2cPhotoSource> onAdd;
  final ValueChanged<C2cParcelPhoto> onRemove;

  const ParcelPhotosPicker({
    super.key,
    required this.photos,
    required this.picking,
    required this.onAdd,
    required this.onRemove,
  });

  Future<void> _chooseSource(BuildContext context) async {
    final C2cPhotoSource? source = await showModalBottomSheet<C2cPhotoSource>(
      context: context,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(Strings.createParcelTakePhoto),
              onTap: () => Navigator.pop(sheetContext, C2cPhotoSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(Strings.createParcelChoosePhotos),
              onTap: () => Navigator.pop(sheetContext, C2cPhotoSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) onAdd(source);
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final double tile = 76.r;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Wrap(
          spacing: AppSpacing.sm.w,
          runSpacing: AppSpacing.sm.h,
          children: <Widget>[
            for (final C2cParcelPhoto photo in photos)
              _Thumb(
                key: ValueKey<String>(photo.path),
                photo: photo,
                size: tile,
                onRemove: () => onRemove(photo),
              ),
            if (photos.length < C2cParcelPhoto.maxCount)
              SizedBox(
                width: tile,
                height: tile,
                child: InkWell(
                  onTap: picking ? null : () => _chooseSource(context),
                  borderRadius: BorderRadius.circular(AppRadius.md.r),
                  child: DashedBorderBox(
                    borderColor: c.secondary,
                    backgroundColor: c.secondaryLight,
                    borderRadius: AppRadius.md,
                    child: Center(
                      child: picking
                          ? SizedBox(
                              width: 22.r,
                              height: 22.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              Icons.add_a_photo_outlined,
                              color: c.secondary,
                              size: 26.r,
                            ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: AppSpacing.xs.h),
        Text(
          Strings.createParcelPhotosHint,
          style: AppTextStyles.caption(color: c.textSecondary),
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  final C2cParcelPhoto photo;
  final double size;
  final VoidCallback onRemove;

  const _Thumb({
    super.key,
    required this.photo,
    required this.size,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md.r),
            child: Image.file(
              File(photo.path),
              fit: BoxFit.cover,
              // Decode at thumbnail size, not the photo's full resolution.
              cacheWidth: (size * MediaQuery.devicePixelRatioOf(context))
                  .round(),
            ),
          ),
          PositionedDirectional(
            top: 2,
            end: 2,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onRemove,
                child: Padding(
                  padding: EdgeInsets.all(2.r),
                  child: Icon(Icons.close, color: Colors.white, size: 16.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
