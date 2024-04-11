import 'package:flutter/material.dart';
import 'package:flutter_application_1/states/task.dart';
import 'package:flutter_application_1/utils.dart';
import 'package:prompt_dialog/prompt_dialog.dart';

class TasksPage extends StatefulWidget {
  final List<Task> tasks;
  const TasksPage({super.key, required this.tasks});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  void newTask() async {
    String name = await prompt(context, title: const Text('New Task Name')) ?? "";
    if (name != "" && context.mounted) {
      DateTime? date = await showDatePicker(
          context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 1000)));
      if (date == null) return;
      setState(() {
        widget.tasks.add(Task(TaskType.assignment, name, date, false));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: GradientFAB(
        onPressed: newTask,
        tooltip: 'New Task',
        child: const Icon(Icons.add_rounded),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: widget.tasks.length,
        itemBuilder: (context, index) => CheckboxListTile(
          title: Text(widget.tasks[index].task),
          value: widget.tasks[index].completed,
          onChanged: (changed) {
            setState(
              () {
                Task task = widget.tasks[index];
                Future.delayed(Durations.long1, () {
                  setState(() => widget.tasks.remove(task));
                });
                widget.tasks[index].completed = true;
              },
            );
          },
        ),
      ),
    );
  }
}
