import 'package:flutter/material.dart';
import 'package:studyappcs/state_managers/firestore_manager.dart';
import 'package:studyappcs/states/task.dart';
import 'package:studyappcs/utils/input_dialogs.dart';

class TaskPopup extends StatefulWidget {
  final Task task;
  final void Function(Task) deleteCallback;
  const TaskPopup({super.key, required this.task, required this.deleteCallback});

  @override
  State<TaskPopup> createState() => _TaskPopupState();
}

class _TaskPopupState extends State<TaskPopup> {
  void edit() async {
    DialogResult result = await doubleInputDialog(
          context,
          'Edit Task',
          Input(name: 'Name', value: widget.task.name),
          Input(name: 'Desc', nullable: true, value: widget.task.desc),
        ) ??
        DialogResult.empty();

    if (result.first == '') return;

    var taskDocs = await FirestoreManager.taskDocs;
    taskDocs.docs.firstWhere((a) => a['name'] == widget.task.name && a['desc'] == widget.task.desc).reference.set({
      'name': result.first,
      'desc': result.second,
    }, merge);

    setState(() {
      widget.task.name = result.first;
      widget.task.desc = result.second;
    });
  }

  void editColor() async {
    Color? color = await showColorPicker(context, widget.task.color);
    if (color == null) return;
    setState(() => widget.task.color = color);
    var taskDocs = await FirestoreManager.taskDocs;
    taskDocs.docs
        .firstWhere((a) => a['name'] == widget.task.name && a['desc'] == widget.task.desc)
        .reference
        .set({'color': color.value}, merge);
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
            TextButton(onPressed: editColor, child: const Text('Edit Color')),
          ],
        ),
      ],
    );
  }
}
