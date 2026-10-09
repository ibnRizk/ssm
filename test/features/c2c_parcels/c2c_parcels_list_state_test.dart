import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/features/c2c_parcels/domain/entities/c2c_parcel.dart';
import 'package:ssm/features/c2c_parcels/domain/entities/c2c_parcel_status.dart';
import 'package:ssm/features/c2c_parcels/presentation/cubit/c2c_parcels_list_state.dart';

C2cParcelSummary _row(int id, C2cParcelStatus status) => C2cParcelSummary(
  id: id,
  reference: 'C2C-$id',
  viewerRole: C2cViewerRole.sender,
  status: status,
  statusVersion: 1,
);

void main() {
  test('active keeps only the parcels that can still move, in order', () {
    final C2cParcelsListLoaded state = C2cParcelsListLoaded(
      parcels: <C2cParcelSummary>[
        _row(1, C2cParcelStatus.outForDelivery),
        _row(2, C2cParcelStatus.delivered),
        _row(3, C2cParcelStatus.cancelled),
        _row(4, C2cParcelStatus.dispatching),
        _row(5, C2cParcelStatus.returnedToSender),
        _row(6, C2cParcelStatus.unknown),
      ],
      page: 1,
      hasMore: false,
    );

    expect(state.active.map((C2cParcelSummary p) => p.id), <int>[1, 4, 6]);
  });
}
