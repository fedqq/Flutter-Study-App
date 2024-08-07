import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:studyappcs/data_managers/firestore_manager.dart' as firestore_manager;
import 'package:studyappcs/states/task.dart';
import 'package:studyappcs/utils/input_dialogs.dart';
import 'package:studyappcs/utils/utils.dart';

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
    await taskDocs.docs.firstWhere((QueryDocumentSnapshot<StrMap> a) => a['name'] == widget.task.name && a['desc'] == widget.task.desc).reference.update(<Object, Object?>{
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
        .firstWhere((QueryDocumentSnapshot<StrMap> a) => a['name'] == widget.task.name && a['desc'] == widget.task.desc)
        .reference
        .update(<Object, Object?>{'color': color.value});
  }

  void delete() {
    widget.deleteCallback(widget.task);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[Text(widget.task.name), IconButton(onPressed: edit, icon: const Icon(Icons.edit_rounded))],
      ),
      content: Text(widget.task.desc),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FilledButton(onPressed: delete, child: const Text('Delete')),
            TextButton(onPressed: editColor, child: const Text('Edit Color')),
          ],
        ),
      ],
    );
}
