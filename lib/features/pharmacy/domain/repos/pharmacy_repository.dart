import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/pharmacy_request.dart';
import '../entities/prescription_image.dart';

enum PrescriptionSource { camera, gallery }

abstract class PharmacyRepository {
  /// Sends [draft] as multipart form data. A store that isn't an active
  /// pharmacy, or a request without text or image, answers 422 — a failure
  /// carrying the backend's message.
  Future<Either<Failure, PharmacyRequestReceipt>> submit(
    PharmacyRequestDraft draft,
  );

  /// Lets the customer photograph or pick a prescription. `Right(null)`
  /// when they cancelled; a [MediaPickerFailure] when the camera or
  /// gallery couldn't be opened (e.g. access denied).
  Future<Either<Failure, PrescriptionImage?>> pickPrescription(
    PrescriptionSource source,
  );
}
