import '/core/base_classes/base_one_response.dart';

class DeleteRespModel extends BaseOneResponse {
  const DeleteRespModel({super.data, super.message, super.value, super.key});

  factory DeleteRespModel.fromJson(Map<String, dynamic> json) =>
      DeleteRespModel(
        data: json['data'],
        message: json['message'],
        key: json['key'],
        value: json['value'],
      );

  Map<String, dynamic> toJson() => {
    'data': data,
    'message': message,
    'key': key,
  };
}
