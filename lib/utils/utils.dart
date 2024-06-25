import 'package:flutter/material.dart';

double radius = 20;
double padding = 3;

const List<Color> gradientColors = [Color.fromARGB(255, 135, 0, 193), Color.fromARGB(255, 34, 0, 253)];

void simpleSnackBar(BuildContext context, String s) async => ScaffoldMessenger.of(context)
  ..clearSnackBars()
  ..showSnackBar(SnackBar(behavior: SnackBarBehavior.floating, content: Text(s)));
