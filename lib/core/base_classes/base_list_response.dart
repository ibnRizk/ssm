import 'package:equatable/equatable.dart';

import '/core/base_classes/pagination.dart';

class BaseListResponse extends Equatable {
  const BaseListResponse({
    this.data,
    this.message,
    this.success,
    this.pagination,
    this.value,
    this.key,
    this.status,
    this.statusCode,
  });
  final String? value;
  final String? key;
  final List<dynamic>? data;
  final String? message;
  final bool? success;
  final Pagination? pagination;
  final int? statusCode;
  final String? status;

  @override
  List<Object?> get props => [
    data,
    message,
    success,
    pagination,
    value,
    key,
    status,
    statusCode,
  ];
}
