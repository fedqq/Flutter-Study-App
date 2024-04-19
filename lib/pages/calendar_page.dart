// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils.dart';
import 'package:flutter_application_1/widgets/day_card.dart';
import 'package:flutter_application_1/states/task.dart';

import 'dart:developer' as developer;

class CalendarPage extends StatefulWidget {
  final List<Task> tasks;
  const CalendarPage({super.key, required this.tasks});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  Set<TaskType> selected = {TaskType.homework};

  Map<DateTime, List<Task>> getDateTasks() {
    Map<DateTime, List<Task>> ret = {};
    for (Task task in widget.tasks) {
      if (!ret.containsKey(task.dueDate)) {
        ret[task.dueDate] = [task];
      } else {
        ret[task.dueDate]!.add(task);
      }
    }
    return ret;
  }

  void newTask(BuildContext context) async {
    DialogResult result =
        await showDoubleInputDialog(context, 'New task', 'Name', 'Description', nullableSecond: true) ?? emptyResult;

    String name = result.first;
    String desc = result.second;

    if (name != "" && context.mounted) {
      DateTime? date = await showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 1000)),
      );
      if (date == null) return;

      Color? newColor = await showColorPicker(context, Colors.blue);
      if (newColor == null) {
        return;
      }

      setState(() {
        widget.tasks.add(Task(TaskType.homework, name, date, false, newColor, desc));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> dates = getDateTasks().keys.toList()
      ..sort((DateTime first, DateTime second) => first.compareTo(second));
    developer.log(dates.length.toString());

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        scrolledUnderElevation: 0,
      ),
      floatingActionButton: GradientFAB(
        onPressed: () => newTask(context),
        tooltip: 'New Task',
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView(
              children: [
                ListView.builder(
                  physics: const ScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: dates.length,
                  itemBuilder: (context, index) => DayCard(
                    date: dates[index],
                    tasks: getDateTasks()[dates[index]] ?? [],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(50.0),
                  child: Center(child: Text('No more upcoming tasks. ')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
