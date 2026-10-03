import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/location/geo_point.dart';

const GeoPoint _riyadh = GeoPoint(latitude: 24.7136, longitude: 46.6753);
const GeoPoint _jeddah = GeoPoint(latitude: 21.4858, longitude: 39.1925);

void main() {
  test('a point is no distance from itself', () {
    expect(_riyadh.distanceKmTo(_riyadh), 0);
  });

  test('Riyadh to Jeddah is about 846 km in a straight line', () {
    expect(_riyadh.distanceKmTo(_jeddah), closeTo(846, 2));
  });

  test('is the same both ways', () {
    expect(
      _riyadh.distanceKmTo(_jeddah),
      closeTo(_jeddah.distanceKmTo(_riyadh), 1e-9),
    );
  });

  test('one thousandth of a degree of latitude is about 111 m', () {
    const GeoPoint north = GeoPoint(latitude: 24.7146, longitude: 46.6753);
    expect(_riyadh.distanceKmTo(north), closeTo(0.111, 0.001));
  });
}
