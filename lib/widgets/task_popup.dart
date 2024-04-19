import 'package:flutter/material.dart';
import 'package:flutter_application_1/states/task.dart';

class TaskPopup extends StatefulWidget {
  final Task task;
  const TaskPopup({super.key, required this.task});

  @override
  State<TaskPopup> createState() => _TaskPopupState();
}

class _TaskPopupState extends State<TaskPopup> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task.task),
    );
  }
}
