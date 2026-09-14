// ignore_for_file: avoid_print

import 'package:flutter_bloc/flutter_bloc.dart';

class IsSelectedCubit extends Cubit<dynamic> {
  IsSelectedCubit() : super(-1);

  void chengeSelected(dynamic pos) {
    emit(pos);
  }
}
