import 'package:flutter/material.dart';

class Theming {
  static double radius = 20;
  static double padding = 3;

  static const List<Color> gradientColors = [Color.fromARGB(255, 135, 0, 193), Color.fromARGB(255, 34, 0, 253)];
}

void simpleSnackBar(BuildContext context, String s) async {
  ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(SnackBar(behavior: SnackBarBehavior.floating, content: Text(s)));
}
