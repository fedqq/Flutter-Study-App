// ignore_for_file: use_build_context_synchronously
// ignore: unused_import
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:studyappcs/data_managers/firestore_manager.dart' as firestore_manager;
import 'package:studyappcs/states/task.dart';
import 'package:studyappcs/utils/input_dialogs.dart';
import 'package:studyappcs/utils/utils.dart';
import 'package:studyappcs/widgets/day_card.dart';
import 'package:studyappcs/widgets/expanding_task_list.dart';

class CalendarPage extends StatefulWidget {
  final List<Task> tasks;
  final List<Task> completedTasks;
  const CalendarPage({super.key, required this.tasks, required this.completedTasks});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> with SingleTickerProviderStateMixin {
  List<Task> timelyTasks = [];
  List<Task> overdueTasks = [];
  late AnimationController controller;
  late Animation<double> animation;
  late ExpansionTileController overdueController;
  late ExpansionTileController completedController;

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
    Map<DateTime, List<Task>> ret = {};
    for (Task task in (late ? overdueTasks : timelyTasks)) {
      if (!ret.containsKey(task.dueDate)) {
        ret[task.dueDate] = [task];
      } else {
        ret[task.dueDate]!.add(task);
      }
    }

    return ret;
  }

  Map<DateTime, List<Task>> getCompletedTasksMap() {
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

  void createTask(BuildContext context) async {
    DialogResult result = await doubleInputDialog(
          context,
          'New task',
          Input(name: 'Name'),
          Input(name: 'Description', nullable: true),
        ) ??
        DialogResult.empty();

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

    setState(() => widget.tasks.add(Task(name, date, newColor, desc, completed: false)));

    var tasksCollection = firestore_manager.taskCollection;
    tasksCollection.doc(name).set({
      'name': name,
      'desc': desc,
      'date': date.millisecondsSinceEpoch,
      'color': newColor.value,
      'completed': false,
    });
  }

  void deleteTask(Task task) async {
    var taskDocs = await firestore_manager.taskDocs;
    try {
      taskDocs.docs
          .firstWhere((a) => a['name'] == task.name && a['date'] == task.dueDate.millisecondsSinceEpoch)
          .reference
          .delete();
    } catch (e) {
      simpleSnackBar(context, 'An unexpected error occured: ${e.toString()}');
    }
    setState(() => widget.tasks.remove(task));
  }

  void deleteCompletedTask(Task task) async {
    var taskDocs = await firestore_manager.taskDocs;
    taskDocs.docs
        .firstWhere((a) => a['name'] == task.name && a['date'] == task.dueDate.millisecondsSinceEpoch)
        .reference
        .delete();
    setState(() => widget.completedTasks.remove(task));
  }

  List<DateTime> sortByDate(Map<DateTime, List<Task>> list) =>
      list.keys.toList()..sort((first, second) => first.compareTo(second));

  void completeTask(Task task) async {
    var taskDocs = await firestore_manager.taskDocs;
    taskDocs.docs
        .firstWhere((a) => a['name'] == task.name && a['date'] == task.dueDate.millisecondsSinceEpoch)
        .reference
        .update({'completed': true});
    setState(() {
      widget.tasks.remove(task);
      widget.completedTasks.add(task);
    });
  }

  @override
  Widget build(BuildContext context) {
    timelyTasks = [];
    overdueTasks = [];
    for (Task task in widget.tasks) {
      ((task.dueDate.compareTo(DateUtils.dateOnly(DateTime.now())) < 0) ? overdueTasks : timelyTasks).add(task);
    }

    List<DateTime> dates = sortByDate(getTasksMap(late: false));
    List<DateTime> lateDates = sortByDate(getTasksMap(late: true));
    List<DateTime> completedDates = sortByDate(getCompletedTasksMap());

    void onExpanded({bool second = false}) {
      if (second) {
        if (completedDates.isNotEmpty) completedController.collapse();
      } else {
        if (lateDates.isNotEmpty) overdueController.collapse();
      }
    }

    controller.forward();

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks'), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () => createTask(context),
        tooltip: 'New Task',
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: dates.length,
                    itemBuilder: (context, index) => AnimatedBuilder(
                      animation: controller,
                      builder: (_, __) => Padding(
                        padding: EdgeInsets.symmetric(vertical: (1 - animation.value) * 30),
                        child: DayCard(
                          date: dates[index],
                          tasks: getTasksMap(late: false)[dates[index]] ?? [],
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
                  padding: EdgeInsets.all(50.0),
                  child: Center(child: Text('No more upcoming tasks. ')),
                ),
              ],
            ),
          ),
          if (overdueTasks.isNotEmpty)
            ExpandingTaskList(
              dates: lateDates,
              tasks: getTasksMap(late: true),
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
              tasks: getCompletedTasksMap(),
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
