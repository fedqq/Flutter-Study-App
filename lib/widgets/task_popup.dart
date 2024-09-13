import 'package:flutter/material.dart';
import 'package:studyappcs/data_managers/firestore_manager.dart' as firestore_manager;
import 'package:studyappcs/states/task.dart';
import 'package:studyappcs/utils/input_dialogs.dart';

class TaskPopup extends StatefulWidget {
  const TaskPopup({super.key, required this.task, required this.deleteCallback});
  final Task task;
  final void Function(Task) deleteCallback;

  @override
  State<TaskPopup> createState() => _TaskPopupState();
}

class _TaskPopupState extends State<TaskPopup> {
  Future<void> edit() async {
    final result = await doubleInputDialog(
          context,
          'Edit Task',
          Input(name: 'Name', value: widget.task.name),
          Input(name: 'Desc', nullable: true, value: widget.task.desc),
        ) ??
        DialogResult.empty;

    if (result.first == '') {
      return;
    }

    final taskDocs = await firestore_manager.taskDocs;
    await taskDocs.docs
        .firstWhere((a) => a['name'] == widget.task.name && a['desc'] == widget.task.desc)
        .reference
        .update({
      'name': result.first,
      'desc': result.second,
    });

    setState(() {
      widget.task.name = result.first;
      widget.task.desc = result.second;
    });
  }

  Future<void> editColor() async {
    final color = await showColorPicker(context, widget.task.color);
    if (color == null) {
      return;
    }
    setState(() => widget.task.color = color);
    final taskDocs = await firestore_manager.taskDocs;
    await taskDocs.docs
        .firstWhere((a) => a['name'] == widget.task.name && a['desc'] == widget.task.desc)
        .reference
        .update({'color': color.value});
  }

  void delete() {
    widget.deleteCallback(widget.task);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
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
              TextButton(onPressed: editColor, child: const Text('Edit Color')),
            ],
          ),
        ],
      );
}
