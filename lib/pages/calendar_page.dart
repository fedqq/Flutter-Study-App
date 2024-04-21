// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils.dart';
import 'package:flutter_application_1/widgets/day_card.dart';
import 'package:flutter_application_1/states/task.dart';
import 'package:flutter_application_1/widgets/input_dialogs.dart';

import 'dart:developer' as developer;

import '../widgets/gradient_widgets.dart';

class CalendarPage extends StatefulWidget {
  final List<Task> tasks;
  const CalendarPage({super.key, required this.tasks});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  Set<TaskType> selected = {TaskType.homework};
  List<Task> timelyTasks = [];
  List<Task> lateTasks = [];

  Map<DateTime, List<Task>> getDateTasks(bool late) {
    Map<DateTime, List<Task>> ret = {};
    for (Task task in (late ? lateTasks : timelyTasks)) {
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
    timelyTasks = [];
    lateTasks = [];
    for (Task task in widget.tasks) {
      if (task.dueDate.compareTo(DateTime.now()) < 0) {
        lateTasks.add(task);
      } else {
        timelyTasks.add(task);
      }
    }

    List<DateTime> dates = getDateTasks(false).keys.toList()
      ..sort((DateTime first, DateTime second) => first.compareTo(second));
    List<DateTime> lateDates = getDateTasks(true).keys.toList()
      ..sort((DateTime first, DateTime second) => first.compareTo(second));
    developer.log(dates.length.toString());

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        scrolledUnderElevation: 0,
      ),
      floatingActionButton: GradientActionButton(
        onPressed: () => newTask(context),
        tooltip: 'New Task',
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          ExpansionTile(
            shape: const Border(),
            title: const Text('Overdue Tasks'),
            children: [
              ListView.builder(
                physics: const ScrollPhysics(),
                shrinkWrap: true,
                itemCount: dates.length,
                itemBuilder: (context, index) => DayCard(
                  date: lateDates[index],
                  tasks: getDateTasks(true)[lateDates[index]] ?? [],
                  overdue: true,
                ),
              )
            ],
          ),
          Container(
            margin: const EdgeInsets.all(16.0),
            width: double.infinity,
            height: 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Theming.grayGradient.colors[1],
            ),
          ),
          Flexible(
            child: ListView(
              children: [
                ListView.builder(
                  physics: const ScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: dates.length,
                  itemBuilder: (context, index) => DayCard(
                    date: dates[index],
                    tasks: getDateTasks(false)[dates[index]] ?? [],
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
