import '../../../domain/entities/address.dart';
import '../address_model.dart';

/// Body of `POST /customer/address/add`.
class AddAddressRequest {
  final NewAddress address;

  const AddAddressRequest(this.address);

  /// Coordinates go as strings, as in the API guide's examples, fixed to 7
  /// decimals (~1 cm) so a double's float noise isn't sent.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'address_type': AddressModel.addressTypeToWire(address.type),
    'contact_person_name': address.contactPersonName,
    'contact_person_number': address.contactPersonNumber,
    'address': address.address,
    'latitude': address.location.latitude.toStringAsFixed(7),
    'longitude': address.location.longitude.toStringAsFixed(7),
  };
}
