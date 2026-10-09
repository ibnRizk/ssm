import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/c2c_parcel_draft.dart';

/// The device camera and photo gallery, for parcel photos.
abstract class C2cPhotoPickerDataSource {
  /// Empty when the customer cancelled. Throws [MediaPickerException] when
  /// the camera or gallery couldn't be opened.
  Future<List<C2cParcelPhoto>> pick(
    C2cPhotoSource source, {
    required int limit,
  });
}

class C2cPhotoPickerDataSourceImpl implements C2cPhotoPickerDataSource {
  final ImagePicker picker;

  C2cPhotoPickerDataSourceImpl({ImagePicker? picker})
    : picker = picker ?? ImagePicker();

  /// Plenty for the driver to recognise the parcel, and a phone photo
  /// shrunk to it lands well under the 5 MB limit. Asking for a resize also
  /// makes iOS hand over a JPEG instead of a HEIC the backend would refuse.
  static const double _maxDimension = 1600;
  static const int _quality = 80;

  @override
  Future<List<C2cParcelPhoto>> pick(
    C2cPhotoSource source, {
    required int limit,
  }) async {
    if (limit <= 0) return const <C2cParcelPhoto>[];
    final List<XFile> files;
    try {
      files = switch (source) {
        C2cPhotoSource.camera => <XFile>[
          ?await picker.pickImage(
            source: ImageSource.camera,
            maxWidth: _maxDimension,
            maxHeight: _maxDimension,
            imageQuality: _quality,
          ),
        ],
        // The platform picker treats a limit of 1 as invalid.
        C2cPhotoSource.gallery when limit == 1 => <XFile>[
          ?await picker.pickImage(
            source: ImageSource.gallery,
            maxWidth: _maxDimension,
            maxHeight: _maxDimension,
            imageQuality: _quality,
          ),
        ],
        C2cPhotoSource.gallery => await picker.pickMultiImage(
          maxWidth: _maxDimension,
          maxHeight: _maxDimension,
          imageQuality: _quality,
          limit: limit,
        ),
      };
    } on PlatformException catch (error) {
      throw MediaPickerException(message: error.message);
    }
    return <C2cParcelPhoto>[
      for (final XFile file in files.take(limit))
        C2cParcelPhoto(
          path: file.path,
          fileName: file.name,
          sizeBytes: await file.length(),
        ),
    ];
  }
}
