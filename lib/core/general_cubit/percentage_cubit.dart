// ignore_for_file: avoid_print

import 'package:flutter_bloc/flutter_bloc.dart';

class PercentageCubit extends Cubit<double> {
  PercentageCubit() : super(0.0);

  void chengePercentage(double pos) {
    emit(pos);
  }
}
