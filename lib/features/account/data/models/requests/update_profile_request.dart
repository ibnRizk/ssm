import '../../../domain/entities/customer_profile.dart';

/// Body of `POST /customer/update-profile`. One `name` field, not
/// `f_name`/`l_name`.
class UpdateProfileRequest {
  final String name;
  final String email;
  final String phone;

  const UpdateProfileRequest({
    required this.name,
    required this.email,
    required this.phone,
  });

  factory UpdateProfileRequest.fromUpdate(ProfileUpdate update) =>
      UpdateProfileRequest(
        name: update.name,
        email: update.email,
        phone: update.phone,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'email': email,
    'phone': phone,
  };
}
