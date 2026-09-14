import '/core/base_classes/pagination.dart';

class PaginationModel extends Pagination {
  const PaginationModel({
    super.currentPage,
    super.lastPage,
    super.perPage,
    super.total,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) =>
      PaginationModel(
        currentPage: json['current_page'],
        lastPage: json['last_page'],
        perPage: json['per_page'],
        total: json['total'],
      );

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'last_page': lastPage,
    'per_page': perPage,
    'total': total,
  };
}
