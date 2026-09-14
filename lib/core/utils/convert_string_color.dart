import 'dart:ui';

Color convertStringColor(String colorCode) =>
    Color(int.parse(colorCode.replaceFirst('#', '0xFF')));
