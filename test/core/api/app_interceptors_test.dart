import 'package:flutter_base/core/api/app_interceptors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppInterceptors.zoneHeaders', () {
    test('sends the zone as a JSON array, with the module', () {
      expect(AppInterceptors.zoneHeaders(<int>[1]), <String, String>{
        'moduleId': '1',
        'zoneId': '[1]',
      });
    });

    test('keeps every zone id', () {
      expect(AppInterceptors.zoneHeaders(<int>[1, 3])['zoneId'], '[1,3]');
    });

    test('omits zoneId until a zone is known', () {
      expect(AppInterceptors.zoneHeaders(<int>[]), <String, String>{
        'moduleId': '1',
      });
    });
  });
}
