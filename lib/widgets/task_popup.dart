import 'package:flutter/material.dart';
import 'package:flutter_application_1/reused_widgets/input_dialogs.dart';
import 'package:flutter_application_1/states/task.dart';

class TaskPopup extends StatefulWidget {
  final Task task;
  final void Function(Task) deleteCallback;
  const TaskPopup({super.key, required this.task, required this.deleteCallback});

  @override
  State<TaskPopup> createState() => _TaskPopupState();
}

class _TaskPopupState extends State<TaskPopup> {
  void edit() async {
    DialogResult result = await showDoubleInputDialog(context, 'Edit Task', 'Name', 'Description',
            nullableSecond: true, initialValue: widget.task.name, initialSecondValue: widget.task.desc) ??
        emptyResult;

    if (result.first == '') return;
    setState(() {
      widget.task.name = result.first;
      widget.task.desc = result.second;
    });
  }

  void editColor() async {
    Color? color = await showColorPicker(context, widget.task.color);
    if (color != null) setState(() => widget.task.color = color);
  }

  void delete() {
    widget.deleteCallback(widget.task);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(widget.task.name), IconButton(onPressed: edit, icon: const Icon(Icons.edit_rounded))],
      ),
      content: Text(widget.task.desc),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FilledButton(onPressed: delete, child: const Text('Delete')),
            TextButton(onPressed: () {}, child: const Text('Edit Color')),
          ],
        )
      ],
    );
  }
}
