import 'package:dio/dio.dart';

import '../../../domain/entities/pharmacy_request.dart';
import '../../../domain/entities/prescription_image.dart';

/// `POST /customer/pharmacy-requests` as multipart form data: text fields,
/// plus the image as the `prescription` file part.
class PharmacyRequestForm {
  final PharmacyRequestDraft draft;

  const PharmacyRequestForm(this.draft);

  /// The text parts. Optional ones are left out rather than sent empty,
  /// which the backend would validate as present-but-blank.
  Map<String, String> get fields {
    final String? text = draft.requestText?.trim();
    return <String, String>{
      'pharmacy_store_id': '${draft.pharmacyStoreId}',
      if (text != null && text.isNotEmpty) 'request_text': text,
      'recipient_name': draft.recipientName,
      'recipient_phone': draft.recipientPhone,
      'delivery_address': draft.deliveryAddress,
      if (draft.location case final location?) ...<String, String>{
        'latitude': '${location.latitude}',
        'longitude': '${location.longitude}',
      },
    };
  }

  Future<FormData> toFormData() async {
    final FormData form = FormData();
    form.fields.addAll(fields.entries);
    final PrescriptionImage? image = draft.prescription;
    if (image != null) {
      form.files.add(
        MapEntry<String, MultipartFile>(
          'prescription',
          await MultipartFile.fromFile(
            image.path,
            filename: image.fileName,
            contentType: DioMediaType('image', mimeSubtype(image)),
          ),
        ),
      );
    }
    return form;
  }

  /// `jpg` is sent as the registered `image/jpeg`.
  static String mimeSubtype(PrescriptionImage image) =>
      image.extension == 'jpg' ? 'jpeg' : image.extension;
}
