import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/utils/uuid.dart';

final RegExp _v4 = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

void main() {
  test('is a version 4, RFC 4122 UUID', () {
    expect(uuidV4(), matches(_v4));
  });

  test('is different every time', () {
    final Set<String> ids = <String>{for (int i = 0; i < 1000; i++) uuidV4()};
    expect(ids, hasLength(1000));
  });
}
