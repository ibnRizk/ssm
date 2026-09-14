import 'package:equatable/equatable.dart';

class Pagination extends Equatable {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;

  const Pagination({this.currentPage, this.lastPage, this.perPage, this.total});

  @override
  List<Object?> get props => [currentPage, lastPage, perPage, total];
}
