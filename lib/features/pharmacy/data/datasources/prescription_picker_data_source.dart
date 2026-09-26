import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/prescription_image.dart';
import '../../domain/repos/pharmacy_repository.dart';

/// The device camera and photo gallery.
abstract class PrescriptionPickerDataSource {
  /// Null when the customer cancelled. Throws [MediaPickerException] when
  /// the camera or gallery couldn't be opened.
  Future<PrescriptionImage?> pick(PrescriptionSource source);
}

class PrescriptionPickerDataSourceImpl implements PrescriptionPickerDataSource {
  final ImagePicker picker;

  PrescriptionPickerDataSourceImpl({ImagePicker? picker})
    : picker = picker ?? ImagePicker();

  /// A prescription stays legible at this size, and a phone photo shrunk to
  /// it lands well under the 10 MB upload limit. Asking for a resize also
  /// makes iOS hand over a JPEG instead of a HEIC the backend would refuse.
  static const double _maxDimension = 2048;
  static const int _quality = 85;

  @override
  Future<PrescriptionImage?> pick(PrescriptionSource source) async {
    final XFile? file;
    try {
      file = await picker.pickImage(
        source: switch (source) {
          PrescriptionSource.camera => ImageSource.camera,
          PrescriptionSource.gallery => ImageSource.gallery,
        },
        maxWidth: _maxDimension,
        maxHeight: _maxDimension,
        imageQuality: _quality,
      );
    } on PlatformException catch (error) {
      throw MediaPickerException(message: error.message);
    }
    if (file == null) return null;
    return PrescriptionImage(
      path: file.path,
      fileName: file.name,
      sizeBytes: await file.length(),
    );
  }
}
