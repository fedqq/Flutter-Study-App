// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/expanding_task_list.dart';
import 'package:flutter_application_1/widgets/day_card.dart';
import 'package:flutter_application_1/states/task.dart';
import 'package:flutter_application_1/reused_widgets/input_dialogs.dart';

// ignore: unused_import
import 'dart:developer' as developer;

import '../reused_widgets/gradient_widgets.dart';

class CalendarPage extends StatefulWidget {
  final List<Task> tasks;
  final List<Task> completedTasks;
  const CalendarPage({super.key, required this.tasks, required this.completedTasks});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> with SingleTickerProviderStateMixin {
  List<Task> timelyTasks = [];
  List<Task> lateTasks = [];
  late AnimationController controller;
  late Animation<double> animation;
  late ExpansionTileController overdueController;
  late ExpansionTileController completedController;

  @override
  void initState() {
    controller = AnimationController(vsync: this, value: 0, duration: Durations.long3);
    overdueController = ExpansionTileController();
    completedController = ExpansionTileController();

    animation = CurvedAnimation(
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOutQuad,
      parent: controller,
    );
    super.initState();
  }

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

  Map<DateTime, List<Task>> getDateCompletedTasks() {
    Map<DateTime, List<Task>> ret = {};
    for (Task task in widget.completedTasks) {
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

    if (name == "") return;

    DateTime? date = await showDatePicker(
      context: context,
      firstDate: DateTime.now().add(const Duration(days: -100)),
      lastDate: DateTime.now().add(const Duration(days: 1000)),
    );

    if (date == null) return;

    Color? newColor = await showColorPicker(context, Colors.blue);
    if (newColor == null) return;

    setState(() => widget.tasks.add(Task(TaskType.homework, name, date, false, newColor, desc)));
  }

  void deleteTask(Task task) => setState(() => widget.tasks.remove(task));

  void deleteCompletedTask(Task task) => setState(() => widget.completedTasks.remove(task));

  List<DateTime> sortByDate(Map<DateTime, List<Task>> list) =>
      list.keys.toList()..sort((first, second) => first.compareTo(second));

  void completeTask(Task task) => setState(() {
        widget.tasks.remove(task);
        widget.completedTasks.add(task);
      });

  @override
  Widget build(BuildContext context) {
    timelyTasks = [];
    lateTasks = [];
    for (Task task in widget.tasks) {
      ((task.dueDate.compareTo(DateTime.now()) < 0) ? lateTasks : timelyTasks).add(task);
    }

    developer.log(widget.completedTasks.toString());

    List<DateTime> dates = sortByDate(getDateTasks(false));
    List<DateTime> lateDates = sortByDate(getDateTasks(true));
    List<DateTime> completedDates = sortByDate(getDateCompletedTasks());

    void onExpanded({bool second = false}) {
      if (second) {
        if (completedDates.isNotEmpty) completedController.collapse();
      } else {
        if (lateDates.isNotEmpty) overdueController.collapse();
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(scrolledUnderElevation: 0),
      floatingActionButton: GradientActionButton(
        onPressed: () => newTask(context),
        tooltip: 'New Task',
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
                    tasks: getDateTasks(false)[dates[index]] ?? [],
                    removeCallback: deleteTask,
                    completeCallback: completeTask,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(50.0),
                  child: Center(child: Text('No more upcoming tasks. ')),
                ),
              ],
            ),
          ),
          if (lateTasks.isNotEmpty)
            ExpandingTaskList(
              dates: lateDates,
              tasks: getDateTasks(true),
              deleteCallback: deleteTask,
              completeCallback: completeTask,
              outlineColor: Colors.red,
              title: 'Overdue Tasks',
              controller: overdueController,
              onExpanded: onExpanded,
            ),
          if (widget.completedTasks.isNotEmpty)
            ExpandingTaskList(
              dates: completedDates,
              tasks: getDateCompletedTasks(),
              deleteCallback: deleteCompletedTask,
              outlineColor: Colors.grey,
              title: 'Completed Tasks',
              controller: overdueController,
              onExpanded: () => onExpanded(second: true),
            ),
        ],
      ),
    );
  }
}
