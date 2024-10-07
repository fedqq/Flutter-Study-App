// ignore_for_file: use_build_context_synchronously
// ignore: unused_import
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:studyappcs/data_managers/firestore_manager.dart' as firestore_manager;
import 'package:studyappcs/states/task.dart';
import 'package:studyappcs/utils/input_dialogs.dart';
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

  //Returns a map of dates where tasks exist, and a list of tasks on that date. 
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

  //Same as the other function, but with completed tasks. 
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

  //Check if a given task name already exists. 
  bool checkExistingTaskName(String name) {
    for (final task in widget.tasks) {
      if (task.name == name) {
        return false;
      }
    }
    return true;
  }

  Future<void> createTask(BuildContext context) async {
    final result = await doubleInputDialog(
          context,
          'New task',
          Input(name: 'Name', validate: checkExistingTaskName),
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
    await tasksCollection.doc().set({
      'name': name,
      'desc': desc,
      'date': date.millisecondsSinceEpoch,
      'color': newColor.value,
      'completed': false,
    });
  }

  Future<void> deleteTask(Task task) async {
    final taskDocs = await firestore_manager.taskDocs;
    await taskDocs.docs.firstWhere((a) => task.isEqualTo(a)).reference.delete();
    setState(() => widget.tasks.remove(task));
  }

  Future<void> deleteCompletedTask(Task task) async {
    final taskDocs = await firestore_manager.taskDocs;
    await taskDocs.docs.firstWhere((a) => task.isEqualTo(a)).reference.delete();
    setState(() => widget.completedTasks.remove(task));
  }

  //Return a sorted list of the dates used as keys in the parameter. 
  List<DateTime> sortByDate(Map<DateTime, List<Task>> list) =>
      list.keys.toList()..sort((first, second) => first.compareTo(second));

  Future<void> completeTask(Task task) async {
    final taskDocs = await firestore_manager.taskDocs;
    await taskDocs.docs.firstWhere((a) => task.isEqualTo(a)).reference.update({'completed': true});
    setState(() {
      widget.tasks.remove(task);
      widget.completedTasks.add(task);
    });
  }

  //Group the tasks based on whether they are late or on time. 
  //Completed tasks are in another list. 
  void regroupTasks() {
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

  //Called when one of the list widgets is expanded. 
  //The parameter determines which list was expanded. 
  void onExpanded({bool completed = false}) {
    if (completed) {
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
        onExpanded: () => onExpanded(completed  : true),
      );

  @override
  Widget build(BuildContext context) {
    controller.forward();
    regroupTasks();

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
                  padding: const EdgeInsets.all(8),
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
