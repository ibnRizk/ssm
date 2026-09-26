import 'package:dartz/dartz.dart';

import '../../../../core/api/safe_api_call.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/pharmacy_request.dart';
import '../../domain/entities/prescription_image.dart';
import '../../domain/repos/pharmacy_repository.dart';
import '../datasources/pharmacy_remote_data_source.dart';
import '../datasources/prescription_picker_data_source.dart';
import '../models/requests/pharmacy_request_form.dart';

class PharmacyRepositoryImpl implements PharmacyRepository {
  final PharmacyRemoteDataSource remote;
  final PrescriptionPickerDataSource picker;

  const PharmacyRepositoryImpl({required this.remote, required this.picker});

  @override
  Future<Either<Failure, PharmacyRequestReceipt>> submit(
    PharmacyRequestDraft draft,
  ) => safeApiCall(() => remote.submit(PharmacyRequestForm(draft)));

  @override
  Future<Either<Failure, PrescriptionImage?>> pickPrescription(
    PrescriptionSource source,
  ) => safeApiCall(() => picker.pick(source));
}
