// ignore: unused_import
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:studyappcs/utils/utils.dart';

class DoubleInputDialog extends StatefulWidget {
  final String title;
  final Input first;
  final Input second;
  final bool cancellable;
  const DoubleInputDialog({
    super.key,
    required this.title,
    required this.first,
    required this.second,
    this.cancellable = true,
  });

  @override
  State<DoubleInputDialog> createState() => _DoubleInputDialogState();
}

class _DoubleInputDialogState extends State<DoubleInputDialog> {
  Widget buildInputField(Input type, Function(String) onChanged) {
    if (!type.exists) return Container();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        keyboardType: type.numerical ? TextInputType.number : TextInputType.name,
        initialValue: type.value,
        onChanged: onChanged,
        autofocus: true,
        decoration: InputDecoration(
          border: const OutlineInputBorder(borderSide: BorderSide()),
          label: Text(type.name ?? ''),
        ),
      ),
    );
  }

  bool validateInput(final Input input) {
    if (!input.exists) return true;

    String value = input.value?.trim() ?? '';
    bool numericalPass = !(input.numerical && int.tryParse(value) == null);
    bool customValidatePass = input.validate == null ? true : input.validate!(value);
    bool basicValidatePass = validInput(value);
    bool emptyPass = input.nullable ? true : value.isNotEmpty;

    return numericalPass && customValidatePass && basicValidatePass && emptyPass;
  }

  @override
  Widget build(BuildContext context) {
    Input first = widget.first;
    Input second = widget.second;

    return AlertDialog(
      contentPadding: const EdgeInsets.all(24.0),
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildInputField(first, (str) {
            first.value = str;
          }),
          buildInputField(second, (str) => second.value = str),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.cancellable)
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(null),
                ),
              FilledButton(
                child: const Text('Confirm'),
                onPressed: () {
                  bool validFirst = validateInput(first);
                  bool validSecond = validateInput(second);
                  if (!(validFirst && validSecond)) {
                    simpleSnackBar(
                      context,
                      'Invalid ${!validFirst ? first.name : second.name}. Please remove any special characters and do not leave it empty. Make sure that any name inputted does not already exist',
                    );

                    return;
                  }
                  Navigator.of(context).pop(DialogResult(first.value ?? '', second.value ?? ''));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Input {
  final String? name;
  final bool exists;
  final bool numerical;
  String? value;
  final bool nullable;
  final bool Function(String)? validate;

  Input({
    this.validate,
    this.exists = true,
    this.name,
    this.numerical = false,
    this.value,
    this.nullable = false,
  });

  static Input notExists() => Input(exists: false);
}

bool validInput(String str) {
  List<String> invalid = ['<', '>', '///', '__', ']', ';', '|'];

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
  static DialogResult empty() => DialogResult('', '');
}

Future<String> singleInputDialog(
  BuildContext context,
  String title,
  Input input, {
  bool cancellable = true,
}) async {
  DialogResult? result = await doubleInputDialog(
    context,
    title,
    input,
    Input.notExists(),
    cancellable: cancellable,
  );

  return result == null ? '' : result.first;
}

Future<DialogResult?> doubleInputDialog(
  BuildContext context,
  String title,
  Input first,
  Input second, {
  bool cancellable = true,
}) async =>
    await showDialog<DialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DoubleInputDialog(
        title: title,
        first: first,
        second: second,
        cancellable: cancellable,
      ),
    );

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
        TextButton(
          onPressed: () => Navigator.pop(context, tempColor),
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
}
