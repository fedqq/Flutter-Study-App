import 'dart:math';
import 'package:flutter/material.dart';

class Theming {
  static double radius = 20;
  static double padding = 3;

  static const purple = Color.fromARGB(255, 135, 0, 193);
  static const blue = Color.fromARGB(255, 34, 0, 253);
  static const gray = Color.fromARGB(130, 224, 224, 224);
  static const grayOpaque = Color.fromARGB(100, 146, 146, 146);

  static const List<Color> gradientColors = [purple, blue];
  static const List<Color> grayGradientColors = [gray, grayOpaque];

  static Color boxShadowColor = gradientColors[1].withAlpha(60);

  static const Gradient coloredGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: gradientColors,
  );

  static const Gradient grayGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: grayGradientColors,
  );

  static BoxDecoration gradientDeco =
      BoxDecoration(gradient: coloredGradient, borderRadius: BorderRadius.circular(radius));

  static BoxDecoration innerDeco = BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: <Color>[Color.fromARGB(255, 15, 15, 15), Color.fromARGB(255, 19, 19, 19)],
    ),
    borderRadius: BorderRadius.circular(radius - padding),
  );

  static BoxDecoration grayDeco = BoxDecoration(gradient: grayGradient, borderRadius: BorderRadius.circular(radius));

  static const BoxDecoration transparent = BoxDecoration(color: Colors.transparent);

  static LinearGradient gradientToDarker(Color color, {double delta = 0.2}) {
    HSLColor hsl = HSLColor.fromColor(color);
    hsl = hsl.withLightness(max(hsl.lightness - delta, 0));

    return LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color, hsl.toColor()]);
  }

  static ButtonStyle transparentButtonStyle = const ButtonStyle(
    shadowColor: MaterialStatePropertyAll(Colors.transparent),
    overlayColor: MaterialStatePropertyAll(Colors.transparent),
    backgroundColor: MaterialStatePropertyAll(Colors.transparent),
    surfaceTintColor: MaterialStatePropertyAll(Colors.transparent),
    foregroundColor: MaterialStatePropertyAll(Colors.white),
    iconColor: MaterialStatePropertyAll(Colors.white),
  );
}
