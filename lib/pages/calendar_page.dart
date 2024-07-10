// ignore_for_file: use_build_context_synchronously
// ignore: unused_import
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:studyappcs/data_managers/firestore_manager.dart' as firestore_manager;
import 'package:studyappcs/states/task.dart';
import 'package:studyappcs/utils/input_dialogs.dart';
import 'package:studyappcs/utils/utils.dart';
import 'package:studyappcs/widgets/day_card.dart';
import 'package:studyappcs/widgets/expanding_task_list.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key, required this.tasks, required this.completedTasks});
  final List<Task> tasks;
  final List<Task> completedTasks;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> with SingleTickerProviderStateMixin {
  List<Task> timelyTasks = <Task>[];
  List<Task> overdueTasks = <Task>[];
  late AnimationController controller;
  late Animation<double> animation;
  late ExpansionTileController overdueController;
  late ExpansionTileController completedController;

  List<DateTime> dates = <DateTime>[];
  List<DateTime> lateDates = <DateTime>[];
  List<DateTime> completedDates = <DateTime>[];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

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

  Map<DateTime, List<Task>> getTasksMap({required bool late}) {
    final ret = <DateTime, List<Task>>{};
    for (final task in (late ? overdueTasks : timelyTasks)) {
      if (!ret.containsKey(task.dueDate)) {
        ret[task.dueDate] = <Task>[task];
      } else {
        ret[task.dueDate]!.add(task);
      }
    }

    return ret;
  }

  Map<DateTime, List<Task>> getCompletedTasksMap() {
    final ret = <DateTime, List<Task>>{};
    for (final task in widget.completedTasks) {
      if (!ret.containsKey(task.dueDate)) {
        ret[task.dueDate] = <Task>[task];
      } else {
        ret[task.dueDate]!.add(task);
      }
    }

    return ret;
  }

  Future<void> createTask(BuildContext context) async {
    final result = await doubleInputDialog(
          context,
          'New task',
          Input(name: 'Name'),
          Input(name: 'Description', nullable: true),
        ) ??
        DialogResult.empty;

    final name = result.first;
    final desc = result.second;

    if (name == '') {
      return;
    }

    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now().add(const Duration(days: -100)),
      lastDate: DateTime.now().add(const Duration(days: 1000)),
    );

    if (date == null) {
      return;
    }

    final newColor = await showColorPicker(context, Colors.blue);
    if (newColor == null) {
      return;
    }

    setState(() => widget.tasks.add(Task(name, date, newColor, desc, completed: false)));

    final tasksCollection = firestore_manager.taskCollection;
    await tasksCollection.doc(name).set(<String, dynamic>{
      'name': name,
      'desc': desc,
      'date': date.millisecondsSinceEpoch,
      'color': newColor.value,
      'completed': false,
    });
  }

  Future<void> deleteTask(Task task) async {
    final taskDocs = await firestore_manager.taskDocs;
    try {
      await taskDocs.docs.firstWhere((QueryDocumentSnapshot<StrMap> a) => task.compare(a)).reference.delete();
    } catch (e) {
      simpleSnackBar(context, 'An unexpected error occured: $e');
    }
    setState(() => widget.tasks.remove(task));
  }

  Future<void> deleteCompletedTask(Task task) async {
    final taskDocs = await firestore_manager.taskDocs;
    await taskDocs.docs.firstWhere((QueryDocumentSnapshot<StrMap> a) => task.compare(a)).reference.delete();
    setState(() => widget.completedTasks.remove(task));
  }

  List<DateTime> sortByDate(Map<DateTime, List<Task>> list) =>
      list.keys.toList()..sort((DateTime first, DateTime second) => first.compareTo(second));

  Future<void> completeTask(Task task) async {
    final taskDocs = await firestore_manager.taskDocs;
    await taskDocs.docs
        .firstWhere((QueryDocumentSnapshot<StrMap> a) => task.compare(a))
        .reference
        .update(<Object, Object?>{'completed': true});
    setState(() {
      widget.tasks.remove(task);
      widget.completedTasks.add(task);
    });
  }

  void updateDates() {
    timelyTasks = <Task>[];
    overdueTasks = <Task>[];
    for (final task in widget.tasks) {
      if (task.dueDate.compareTo(DateUtils.dateOnly(DateTime.now())) < 0) {
        overdueTasks.add(task);
      } else {
        timelyTasks.add(task);
      }
    }

    dates = sortByDate(getTasksMap(late: false));
    lateDates = sortByDate(getTasksMap(late: true));
    completedDates = completedTaskDates;
  }

  List<DateTime> get completedTaskDates => sortByDate(getCompletedTasksMap());

  void onExpanded({bool second = false}) {
    if (second) {
      if (completedDates.isNotEmpty) {
        completedController.collapse();
      }
    } else if (lateDates.isNotEmpty) {
      overdueController.collapse();
    }
  }

  Widget buildOverdueList() => ExpandingTaskList(
        dates: lateDates,
        tasks: getTasksMap(late: true),
        deleteCallback: deleteTask,
        completeCallback: completeTask,
        outlineColor: Colors.red,
        title: 'Overdue Tasks',
        controller: overdueController,
        onExpanded: onExpanded,
      );

  Widget buildCompletedList() => ExpandingTaskList(
        dates: completedDates,
        tasks: getCompletedTasksMap(),
        deleteCallback: deleteCompletedTask,
        outlineColor: Colors.grey,
        title: 'Completed Tasks',
        controller: overdueController,
        onExpanded: () => onExpanded(second: true),
      );

  @override
  Widget build(BuildContext context) {
    controller.forward();

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks'), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () => createTask(context),
        tooltip: 'New Task',
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ListView.builder(
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: dates.length,
                    itemBuilder: (BuildContext context, int index) => AnimatedBuilder(
                      animation: controller,
                      builder: (_, __) => Padding(
                        padding: EdgeInsets.symmetric(vertical: (1 - animation.value) * 30),
                        child: DayCard(
                          date: dates[index],
                          tasks: getTasksMap(late: false)[dates[index]] ?? <Task>[],
                          removeCallback: deleteTask,
                          completeCallback: completeTask,
                          progress: animation.value,
                          positionInList: index == 0 ? 0 : (index == dates.length - 1 ? 2 : 1),
                        ),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(50),
                  child: Center(child: Text('No more upcoming tasks. ')),
                ),
              ],
            ),
          ),
          if (overdueTasks.isNotEmpty) buildOverdueList(),
          if (widget.completedTasks.isNotEmpty) buildCompletedList(),
        ],
      ),
    );
  }
}
