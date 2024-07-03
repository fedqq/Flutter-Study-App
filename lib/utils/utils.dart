import 'package:flutter/material.dart';

double radius = 20;
double padding = 3;

typedef StrMap = Map<String, dynamic>;

const List<Color> gradientColors = <Color>[Color.fromARGB(255, 135, 0, 193), Color.fromARGB(255, 34, 0, 253)];

void simpleSnackBar(BuildContext context, String s) => ScaffoldMessenger.of(context)
  ..clearSnackBars()
  ..showSnackBar(SnackBar(behavior: SnackBarBehavior.floating, content: Text(s)));
