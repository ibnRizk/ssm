import 'package:equatable/equatable.dart';

enum PrescriptionImageIssue { tooLarge, unsupportedType }

/// A photo of a prescription, picked on the device, to attach to a pharmacy
/// request.
class PrescriptionImage extends Equatable {
  /// Where the picked file lives on the device.
  final String path;
  final String fileName;
  final int sizeBytes;

  const PrescriptionImage({
    required this.path,
    required this.fileName,
    required this.sizeBytes,
  });

  /// The backend's upload limit.
  static const int maxBytes = 10 * 1024 * 1024;

  /// The formats the backend accepts, by file extension.
  static const Set<String> allowedExtensions = <String>{
    'jpg',
    'jpeg',
    'png',
    'webp',
  };

  /// Lower-case, without the dot; empty when the name has none.
  String get extension {
    final int dot = fileName.lastIndexOf('.');
    return dot < 0 ? '' : fileName.substring(dot + 1).toLowerCase();
  }

  /// Why the backend would refuse this image, or null when it's fine.
  PrescriptionImageIssue? get issue {
    if (!allowedExtensions.contains(extension)) {
      return PrescriptionImageIssue.unsupportedType;
    }
    if (sizeBytes > maxBytes) return PrescriptionImageIssue.tooLarge;
    return null;
  }

  @override
  List<Object?> get props => [path, fileName, sizeBytes];
}
