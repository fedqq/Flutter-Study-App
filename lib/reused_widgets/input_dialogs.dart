import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

bool validInput(String str) {
  List<String> invalid = [',', '[', ']', '{', '}', '-', '=', '!', '*'];
  for (String c in invalid) {
    if (str.contains(c)) {
      return false;
    }
  }
  return true;
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
  bool cancellable = true,
}) async {
  DialogResult? result = await showDoubleInputDialog(
    context,
    title,
    name,
    '',
    initialValue: initialValue,
    extraValidateFirst: extraValidate,
    cancellable: cancellable,
  );

  if (result == null) {
    return '';
  } else {
    return result.first;
  }
}

Future<DialogResult?> showDoubleInputDialog(
  BuildContext context,
  String title,
  String first,
  String second, {
  bool nullableSecond = false,
  String initialValue = '',
  bool Function(String)? extraValidateFirst,
  bool cancellable = true,
}) async {
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
              if (cancellable)
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