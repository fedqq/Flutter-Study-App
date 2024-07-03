// ignore: unused_import
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:studyappcs/utils/utils.dart';

class DoubleInputDialog extends StatefulWidget {
  const DoubleInputDialog({
    super.key,
    required this.title,
    required this.first,
    required this.second,
    this.cancellable = true,
  });
  final String title;
  final Input first;
  final Input second;
  final bool cancellable;

  @override
  State<DoubleInputDialog> createState() => _DoubleInputDialogState();
}

class _DoubleInputDialogState extends State<DoubleInputDialog> {
  Widget buildInputField(Input type, Function(String) onChanged) {
    if (!type.exists) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextFormField(
        keyboardType: type.numerical ? TextInputType.number : TextInputType.name,
        initialValue: type.value,
        onChanged: onChanged,
        autofocus: true,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          label: Text(type.name ?? ''),
        ),
      ),
    );
  }

  bool validateInput(Input input) {
    if (!input.exists) {
      return true;
    }

    final String value = input.value?.trim() ?? '';
    final bool numericalPass = !(input.numerical && int.tryParse(value) == null);
    final bool customValidatePass = input.validate == null || input.validate!(value);
    final bool emptyPass = input.nullable || value.isNotEmpty;

    return numericalPass && customValidatePass && emptyPass;
  }

  @override
  Widget build(BuildContext context) {
    final Input first = widget.first;
    final Input second = widget.second;

    return AlertDialog(
      contentPadding: const EdgeInsets.all(24),
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          buildInputField(first, (String str) {
            first.value = str;
          }),
          buildInputField(second, (String str) => second.value = str),
        ],
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              if (widget.cancellable)
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              FilledButton(
                child: const Text('Confirm'),
                onPressed: () {
                  final bool validFirst = validateInput(first);
                  final bool validSecond = validateInput(second);
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
  Input({
    this.validate,
    this.exists = true,
    this.name,
    this.numerical = false,
    this.value,
    this.nullable = false,
  });
  final String? name;
  final bool exists;
  final bool numerical;
  String? value;
  final bool nullable;
  final bool Function(String)? validate;

  static Input notExists = Input(exists: false);
}

Future<bool> confirmDialog(BuildContext context, {required String title}) async => await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: const Text('Are you sure you would like to continue?'),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: <Widget>[
          FilledButton.tonal(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm')),
        ],
      ),
    );

class DialogResult {
  DialogResult(this.first, this.second);
  String first = '';
  String second = '';
  static DialogResult empty = DialogResult('', '');
}

Future<String> singleInputDialog(
  BuildContext context,
  String title,
  Input input, {
  bool cancellable = true,
}) async {
  final DialogResult? result = await doubleInputDialog(
    context,
    title,
    input,
    Input.notExists,
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
    showDialog<DialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => DoubleInputDialog(
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
      contentPadding: const EdgeInsets.all(8),
      title: const Text('Choose a color'),
      content: MaterialColorPicker(
        onColorChange: (Color value) => tempColor = value,
        selectedColor: color,
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.pop(context, tempColor),
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
}
