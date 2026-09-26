import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../models/pharmacy_request_receipt_model.dart';
import '../models/requests/pharmacy_request_form.dart';

abstract class PharmacyRemoteDataSource {
  Future<PharmacyRequestReceiptModel> submit(PharmacyRequestForm form);
}

class PharmacyRemoteDataSourceImpl implements PharmacyRemoteDataSource {
  final DioConsumer consumer;

  const PharmacyRemoteDataSourceImpl({required this.consumer});

  /// Answers 201 — Dio treats any 2xx as success. Dio sets the multipart
  /// content type (with its boundary) itself for form data.
  @override
  Future<PharmacyRequestReceiptModel> submit(PharmacyRequestForm form) async =>
      PharmacyRequestReceiptModel.fromJson(
        await consumer.post(
          ApiEndpoints.pharmacyRequests,
          formData: await form.toFormData(),
        ),
      );
}
