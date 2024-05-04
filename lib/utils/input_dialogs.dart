import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/snackbar.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
// ignore: unused_import
import 'dart:developer' as developer;

import 'package:latext/latext.dart';

class DoubleInputDialog extends StatefulWidget {
  final String title;
  final InputType first;
  final InputType second;
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
  Widget buildInfoButton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: IconButton(
        icon: const Icon(Icons.info_rounded),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
            ],
            content: LaTexT(
              equationStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(height: 10),
              laTeXCode: Text(getLatexHelpText()),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputField(InputType type, Function(String) onChanged) {
    if (!type.exists) return Container();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        keyboardType: type.numerical ? TextInputType.number : TextInputType.name,
        initialValue: type.initialValue,
        onChanged: onChanged,
        autofocus: true,
        decoration: InputDecoration(
          border: const OutlineInputBorder(borderSide: BorderSide()),
          label: Text(type.name ?? ''),
        ),
      ),
    );
  }

  bool validateInput(InputType input, String? untrimmed) {
    if (!input.exists) return true;

    String value = untrimmed == '' || untrimmed == null ? '' : untrimmed.trim();
    bool numericalPass = !(input.numerical && int.tryParse(value) == null);
    bool customValidatePass = input.validate == null ? true : input.validate!(value);
    bool basicValidatePass = validInput(value);
    bool emptyPass = input.nullable ? true : value.isNotEmpty;

    return numericalPass && customValidatePass && basicValidatePass && emptyPass;
  }

  String getLatexHelpText() {
    String n = r'\n\n';
    String string = r'Texts inputted as a meaning for a card will automatically be rendered using LaTeX rendering' + n;
    string += r"Start a LaTeX script with a dollar sign and don't forget to close it with another dollar sign\n\n";
    string += r"Useful commands for LaTeX:\n\n";
    string += r"\sin => $\sin$ (works for cos tan and sin)" + n;
    string += r"a_b^x => $a_b^x$" + n;
    string += r"\frac {a} {b} => $\frac a b$" + n;
    string += r"\Delta => $\Delta$ (can be capitalized and changed for every greek letter)" + n;
    string += r"\sqrt{a} => $\sqrt{a}$" + n;

    return string;
  }

  @override
  Widget build(BuildContext context) {
    InputType first = widget.first;
    InputType second = widget.second;

    String? firstStr = first.initialValue;
    String? secondStr = second.initialValue;

    return AlertDialog(
      contentPadding: const EdgeInsets.all(24.0),
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildInputField(first, (str) => firstStr = str),
          buildInputField(second, (str) => secondStr = str),
          if (second.latex) buildInfoButton(context),
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
                  onPressed: () => Navigator.of(context).pop(DialogResult.empty()),
                ),
              FilledButton(
                child: const Text('Confirm'),
                onPressed: () {
                  bool validFirst = validateInput(first, firstStr);
                  bool validSecond = validateInput(second, secondStr);
                  if (!(validFirst && validSecond)) {
                    simpleSnackBar(
                      context,
                      'Invalid ${!validFirst ? first.name : second.name}. Please remove any special characters and do not leave it empty',
                    );

                    return;
                  }
                  Navigator.of(context).pop(DialogResult(firstStr ?? '', secondStr ?? ''));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class InputType {
  final String? name;
  final bool exists;
  final bool numerical;
  final String? initialValue;
  final bool nullable;
  final bool latex;
  final bool Function(String)? validate;

  InputType({
    this.validate,
    this.exists = true,
    this.name,
    this.numerical = false,
    this.initialValue,
    this.nullable = false,
    this.latex = false,
  });

  static InputType notExists() => InputType(exists: false);
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

Future<String?> singleInputDialog(
  BuildContext context,
  String title,
  InputType input, {
  bool cancellable = true,
}) async {
  DialogResult? result = await doubleInputDialog(
    context,
    title,
    input,
    InputType.notExists(),
    cancellable: cancellable,
  );

  return result == null ? '' : result.first;
}

Future<DialogResult?> doubleInputDialog(
  BuildContext context,
  String title,
  InputType first,
  InputType second, {
  bool cancellable = true,
}) async =>
    await showDialog<DialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DoubleInputDialog(title: title, first: first, second: second),
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
