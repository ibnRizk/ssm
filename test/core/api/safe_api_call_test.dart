import 'package:dartz/dartz.dart';
import 'package:flutter_base/core/api/safe_api_call.dart';
import 'package:flutter_base/core/error/exceptions.dart';
import 'package:flutter_base/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('wraps a result in Right', () async {
    expect(await safeApiCall(() async => 42), const Right<Failure, int>(42));
  });

  test('maps an AppException to its typed failure', () async {
    expect(
      await safeApiCall<int>(
        () async => throw const UnauthorizedException(message: 'x'),
      ),
      const Left<Failure, int>(UnauthorizedFailure(message: 'x')),
    );
  });

  test('maps any other error to ServerFailure', () async {
    expect(
      await safeApiCall<int>(() async => throw StateError('boom')),
      const Left<Failure, int>(ServerFailure()),
    );
  });
}
