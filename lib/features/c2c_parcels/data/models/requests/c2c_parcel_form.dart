import 'package:dio/dio.dart';

import '../../../../../core/utils/money_format.dart';
import '../../../domain/entities/c2c_parcel_draft.dart';

/// `POST /customer/c2c-parcels` as multipart form data: text fields, plus
/// every photo as an `images[]` file part.
class C2cParcelForm {
  final C2cParcelDraft draft;

  const C2cParcelForm(this.draft);

  /// The text parts. Optional ones are left out rather than sent empty,
  /// which the backend would validate as present-but-blank. Booleans go as
  /// `1` / `0`, as in the API guide.
  Map<String, String> get fields {
    final C2cParcelDraft d = draft;
    return <String, String>{
      ..._contact('sender', d.sender),
      ..._contact('recipient', d.recipient),
      'category': d.request.category.name,
      'weight_kg': '${d.request.weightKg}',
      'is_fragile': d.request.isFragile ? '1' : '0',
      'title': d.title.trim(),
      ..._optional('description', d.description),
      if (d.declaredValue case final double value)
        'declared_value': formatAmount(value),
      ..._optional('pickup_instructions', d.pickupInstructions),
      ..._optional('delivery_instructions', d.deliveryInstructions),
      'payment_method': d.paymentMethod.wire,
      'prohibited_items_acknowledged': d.prohibitedItemsAcknowledged
          ? '1'
          : '0',
      ..._optional('quote_token', d.quoteToken),
    };
  }

  Future<FormData> toFormData() async {
    final FormData form = FormData();
    form.fields.addAll(fields.entries);
    for (final C2cParcelPhoto photo in draft.photos) {
      form.files.add(
        MapEntry<String, MultipartFile>(
          'images[]',
          await MultipartFile.fromFile(
            photo.path,
            filename: photo.fileName,
            contentType: DioMediaType('image', mimeSubtype(photo)),
          ),
        ),
      );
    }
    return form;
  }

  /// `jpg` is sent as the registered `image/jpeg`.
  static String mimeSubtype(C2cParcelPhoto photo) =>
      photo.extension == 'jpg' ? 'jpeg' : photo.extension;

  static Map<String, String> _contact(String prefix, C2cContact contact) =>
      <String, String>{
        '${prefix}_name': contact.name.trim(),
        '${prefix}_phone': contact.phone.trim(),
        '${prefix}_address': contact.address.trim(),
        '${prefix}_latitude': '${contact.location.latitude}',
        '${prefix}_longitude': '${contact.location.longitude}',
        ..._optional('${prefix}_building', contact.building),
        ..._optional('${prefix}_floor', contact.floor),
        ..._optional('${prefix}_apartment', contact.apartment),
        ..._optional('${prefix}_notes', contact.notes),
      };

  static Map<String, String> _optional(String key, String? value) {
    final String? trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty
        ? const <String, String>{}
        : <String, String>{key: trimmed};
  }
}
