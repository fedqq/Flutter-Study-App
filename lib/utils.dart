import "package:flutter/material.dart";
import 'dart:math';

import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

Future<Color?> showColorPicker(BuildContext context, Color color) async {
  Color tempColor = color;
  return showDialog<Color>(
    context: context,
    builder: (_) => AlertDialog(
      contentPadding: const EdgeInsets.all(8.0),
      title: const Text('Choose a color'),
      content: MaterialColorPicker(
        onColorChange: (value) => tempColor = value,
        selectedColor: color,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(context, tempColor), child: const Text('Confirm'))
      ],
    ),
  );
}

class DialogResult {
  String first = '';
  String second = '';

  DialogResult(this.first, this.second);
}

DialogResult emptyResult = DialogResult('', '');

Future<String?> showInputDialog(
  BuildContext context,
  String title,
  String name, {
  String initialValue = '',
  bool Function(String)? extraValidate,
}) async {
  DialogResult? result = await showDoubleInputDialog(
    context,
    title,
    name,
    '',
    initialValue: initialValue,
    extraValidateFirst: extraValidate,
  );

  if (result == null) {
    return '';
  } else {
    return result.first;
  }
}

Future<DialogResult?> showDoubleInputDialog(BuildContext context, String title, String first, String second,
    {bool nullableSecond = false, String initialValue = '', bool Function(String)? extraValidateFirst}) async {
  String? firstStr = '';
  String? secondStr = second == '' ? '404' : '';
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      contentPadding: const EdgeInsets.all(24.0),
      title: Text(
        title,
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              initialValue: initialValue,
              onChanged: (newText) => firstStr = newText,
              autofocus: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: first,
              ),
            ),
          ),
          if (second != '')
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (newText) => secondStr = newText,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: second,
                ),
              ),
            ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  firstStr = '';
                  secondStr = '';
                  Navigator.of(context).maybePop();
                },
              ),
              FilledButton(
                child: const Text('Confirm'),
                onPressed: () {
                  bool extraValidated = true;
                  if (extraValidateFirst != null) {
                    extraValidated = extraValidateFirst(first);
                  }

                  bool validFirst = (firstStr != '');

                  bool hasSecond = (second != '');
                  bool validSecond = true;

                  if (hasSecond) {
                    if (!nullableSecond && secondStr == '') {
                      validSecond = false;
                    }
                  }

                  validFirst = validInput(firstStr ?? '') && extraValidated && validFirst;
                  validSecond = validInput(secondStr ?? '') && validSecond;

                  if (!validFirst) {
                    simpleSnackBar(context,
                        'Invalid ${first.toLowerCase()}. Please remove any special characters and do not leave ${first.toLowerCase()} empty. ');
                    return;
                  }

                  if (hasSecond && !validSecond) {
                    simpleSnackBar(context,
                        'Invalid ${second.toLowerCase()}. Please remove any special characters and do not leave ${second.toLowerCase()} empty. ');
                    return;
                  }

                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
  return DialogResult(firstStr ?? '', secondStr ?? '');
}

bool validInput(String str) {
  List<String> invalid = [',', '[', ']', '{', '}', '-', '=', '!', '*'];
  for (String c in invalid) {
    if (str.contains(c)) {
      return false;
    }
  }
  return true;
}

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

Future<void> simpleSnackBar(BuildContext context, String s) async =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
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
