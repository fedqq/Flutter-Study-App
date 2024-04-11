import "package:flutter/material.dart";
import 'dart:math';

class GradientOutline extends StatelessWidget {
  final Widget? child;
  final Gradient gradient;
  final double outerPadding;
  const GradientOutline(
      {super.key, required this.child, this.gradient = Theming.coloredGradient, this.outerPadding = 0.0});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: Theming.transparent,
        padding: const EdgeInsets.all(15),
        child: Container(
            decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(Theming.radius)),
            padding: EdgeInsets.all(Theming.padding),
            child: Container(decoration: Theming.innerDeco, padding: EdgeInsets.all(outerPadding), child: child)));
  }
}

void basicSnackBar(BuildContext context, String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(s),
    ));

class GradientFAB extends StatelessWidget {
  final Function() onPressed;
  final String tooltip;
  final Widget child;
  const GradientFAB({super.key, required this.onPressed, required this.tooltip, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        decoration: Theming.gradientDeco,
        child: FloatingActionButton(
          onPressed: onPressed,
          tooltip: tooltip,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          hoverElevation: 0,
          child: child,
        ),
      );
}

class Theming {
  static double radius = 20;
  static double padding = 3;

  static const List<Color> gradientColors = [Color.fromARGB(255, 135, 0, 193), Color.fromARGB(255, 34, 0, 253)];

  static Color boxShadowColor = gradientColors[1].withAlpha(60);

  static const Gradient coloredGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: gradientColors,
  );

  static const Gradient grayGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color.fromARGB(130, 224, 224, 224), Color.fromARGB(100, 146, 146, 146)]);

  static BoxDecoration gradientDeco =
      BoxDecoration(gradient: coloredGradient, borderRadius: BorderRadius.circular(radius));

  static BoxDecoration innerDeco = BoxDecoration(
      gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[Color.fromARGB(255, 15, 15, 15), Color.fromARGB(255, 19, 19, 19)]),
      borderRadius: BorderRadius.circular(radius - padding));

  static BoxDecoration grayDeco = BoxDecoration(gradient: grayGradient, borderRadius: BorderRadius.circular(radius));

  static const BoxDecoration transparent = BoxDecoration(color: Colors.transparent);

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
