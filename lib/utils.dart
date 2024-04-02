import "package:flutter/material.dart";
import 'dart:math';

class Theming {
  static double radius = 20;
  static double padding = 3;

  static BoxDecoration gradientDeco = BoxDecoration(
      gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color.fromARGB(255, 135, 0, 193), Color.fromARGB(255, 34, 0, 253)]),
      borderRadius: BorderRadius.circular(radius));

  static BoxDecoration innerDeco = BoxDecoration(
      gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[Color.fromARGB(255, 15, 15, 15), Color.fromARGB(255, 19, 19, 19)]),
      borderRadius: BorderRadius.circular(radius - padding));

  static BoxDecoration grayDeco = BoxDecoration(
      gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color.fromARGB(130, 224, 224, 224), Color.fromARGB(100, 146, 146, 146)]),
      borderRadius: BorderRadius.circular(radius));

  static const BoxDecoration transparent = BoxDecoration(color: Colors.transparent);

  static Container grayOutline(Widget child) {
    return Container(
        decoration: transparent,
        padding: const EdgeInsets.all(15),
        child: Container(
            decoration: grayDeco,
            padding: EdgeInsets.all(padding),
            child: Container(decoration: innerDeco, child: child)));
  }

  static Container gradientOutline(Widget child) {
    return Container(
        decoration: transparent,
        padding: const EdgeInsets.all(15),
        child: Container(
            decoration: gradientDeco,
            padding: EdgeInsets.all(padding),
            child: Container(decoration: innerDeco, child: child)));
  }

  static LinearGradient gradientToDarker(Color color) {
    HSLColor hsl = HSLColor.fromColor(color);
    hsl = hsl.withLightness(max(hsl.lightness - 0.2, 0));
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
