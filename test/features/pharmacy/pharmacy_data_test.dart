import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:ssm/core/api/api_endpoints.dart';
import 'package:ssm/core/error/exceptions.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/core/location/geo_point.dart';
import 'package:ssm/features/pharmacy/data/datasources/pharmacy_remote_data_source.dart';
import 'package:ssm/features/pharmacy/data/datasources/prescription_picker_data_source.dart';
import 'package:ssm/features/pharmacy/data/models/pharmacy_request_receipt_model.dart';
import 'package:ssm/features/pharmacy/data/models/requests/pharmacy_request_form.dart';
import 'package:ssm/features/pharmacy/data/repos/pharmacy_repository_impl.dart';
import 'package:ssm/features/pharmacy/domain/entities/pharmacy_request.dart';
import 'package:ssm/features/pharmacy/domain/entities/prescription_image.dart';
import 'package:ssm/features/pharmacy/domain/repos/pharmacy_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_dio_consumer.dart';

class _UnusedPicker implements PrescriptionPickerDataSource {
  @override
  Future<PrescriptionImage?> pick(PrescriptionSource source) =>
      throw UnimplementedError();
}

PharmacyRequestDraft _draft({
  String? text = 'Vitamin D 50000',
  PrescriptionImage? prescription,
  GeoPoint? location = const GeoPoint(latitude: 24.71, longitude: 46.68),
}) => PharmacyRequestDraft(
  pharmacyStoreId: 4,
  requestText: text,
  prescription: prescription,
  recipientName: 'Sara Customer',
  recipientPhone: '+966512345678',
  deliveryAddress: 'Olaya St 12, Riyadh',
  location: location,
);

void main() {
  group('PrescriptionImage.issue', () {
    PrescriptionImage image(String name, int bytes) =>
        PrescriptionImage(path: '/tmp/$name', fileName: name, sizeBytes: bytes);

    test('accepts jpg, jpeg, png and webp up to 10 MB', () {
      for (final String name in <String>[
        'a.jpg',
        'a.JPEG',
        'a.png',
        'a.webp',
      ]) {
        expect(image(name, PrescriptionImage.maxBytes).issue, isNull);
      }
    });

    test('refuses anything larger than 10 MB', () {
      expect(
        image('a.jpg', PrescriptionImage.maxBytes + 1).issue,
        PrescriptionImageIssue.tooLarge,
      );
    });

    test('refuses other formats, and names without an extension', () {
      expect(image('a.heic', 1).issue, PrescriptionImageIssue.unsupportedType);
      expect(image('scan', 1).issue, PrescriptionImageIssue.unsupportedType);
    });
  });

  group('PharmacyRequestDraft.hasContent', () {
    test('needs a text, an image, or both', () {
      const PrescriptionImage image = PrescriptionImage(
        path: '/tmp/a.png',
        fileName: 'a.png',
        sizeBytes: 1,
      );
      expect(
        PharmacyRequestDraft.hasContent(requestText: '   ', prescription: null),
        isFalse,
      );
      expect(
        PharmacyRequestDraft.hasContent(requestText: 'x', prescription: null),
        isTrue,
      );
      expect(
        PharmacyRequestDraft.hasContent(requestText: '', prescription: image),
        isTrue,
      );
    });
  });

  group('PharmacyRequestForm', () {
    test('sends every field the backend reads', () {
      expect(PharmacyRequestForm(_draft()).fields, <String, String>{
        'pharmacy_store_id': '4',
        'request_text': 'Vitamin D 50000',
        'recipient_name': 'Sara Customer',
        'recipient_phone': '+966512345678',
        'delivery_address': 'Olaya St 12, Riyadh',
        'latitude': '24.71',
        'longitude': '46.68',
      });
    });

    test('leaves out a blank text and a missing pin', () {
      final Map<String, String> fields = PharmacyRequestForm(
        _draft(text: '  ', location: null),
      ).fields;

      expect(
        fields.keys,
        isNot(containsAll(<String>['request_text', 'latitude', 'longitude'])),
      );
    });

    test('attaches the image as the prescription file part', () async {
      final Directory dir = await Directory.systemTemp.createTemp('rx');
      addTearDown(() => dir.delete(recursive: true));
      final File file = File('${dir.path}/rx.jpg')
        ..writeAsBytesSync(<int>[1, 2, 3]);

      final FormData form = await PharmacyRequestForm(
        _draft(
          prescription: PrescriptionImage(
            path: file.path,
            fileName: 'rx.jpg',
            sizeBytes: 3,
          ),
        ),
      ).toFormData();

      final MultipartFile part = form.files.single.value;
      expect(form.files.single.key, 'prescription');
      expect(part.filename, 'rx.jpg');
      expect(part.contentType.toString(), 'image/jpeg');
    });
  });

  group('PharmacyRequestReceiptModel.fromJson', () {
    test('reads the request id and the price disclaimer', () {
      final PharmacyRequestReceipt receipt =
          PharmacyRequestReceiptModel.fromJson(<String, dynamic>{
            'pharmacy_request': <String, dynamic>{
              'id': 12,
              'has_prescription': true,
            },
            'warning': 'Prices may change based on availability.',
          });

      expect(receipt.id, 12);
      expect(receipt.warning, 'Prices may change based on availability.');
    });

    test('throws ServerException without the request id', () {
      expect(
        () => PharmacyRequestReceiptModel.fromJson(<String, dynamic>{
          'warning': 'x',
        }),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('PharmacyRepositoryImpl.submit', () {
    late FakeDioConsumer consumer;
    late PharmacyRepositoryImpl repository;

    setUp(() {
      consumer = FakeDioConsumer(
        response: <String, dynamic>{
          'pharmacy_request': <String, dynamic>{'id': 12},
          'warning': 'Prices may change.',
        },
      );
      repository = PharmacyRepositoryImpl(
        remote: PharmacyRemoteDataSourceImpl(consumer: consumer),
        picker: _UnusedPicker(),
      );
    });

    test('posts multipart form data to the pharmacy requests route', () async {
      final Either<Failure, PharmacyRequestReceipt> result = await repository
          .submit(_draft());

      expect(
        result,
        const Right<Failure, PharmacyRequestReceipt>(
          PharmacyRequestReceiptModel(id: 12, warning: 'Prices may change.'),
        ),
      );
      expect(consumer.lastPath, ApiEndpoints.pharmacyRequests);
      expect(consumer.lastBody, isNull, reason: 'not a JSON body');
      expect(
        Map<String, String>.fromEntries(consumer.lastFormData!.fields),
        PharmacyRequestForm(_draft()).fields,
      );
    });

    test('a refusal (e.g. not a pharmacy) maps to a failure', () async {
      consumer.error = const ServerException(
        message: 'The selected store is not an active pharmacy.',
      );

      final Either<Failure, PharmacyRequestReceipt> result = await repository
          .submit(_draft());

      expect(
        result,
        const Left<Failure, PharmacyRequestReceipt>(
          ServerFailure(
            message: 'The selected store is not an active pharmacy.',
          ),
        ),
      );
    });
  });
}
