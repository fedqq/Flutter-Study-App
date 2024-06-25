import 'package:flutter/material.dart';
import 'package:studyappcs/states/task.dart';
import 'package:studyappcs/widgets/day_card.dart';

class ExpandingTaskList extends StatefulWidget {
  final List<DateTime> dates;
  final Map<DateTime, List<Task>> tasks;
  final Function(Task) deleteCallback;
  final Function(Task)? completeCallback;
  final Color? outlineColor;
  final String title;
  final ExpansionTileController controller;
  final void Function() onExpanded;
  const ExpandingTaskList({
    super.key,
    required this.dates,
    required this.tasks,
    required this.deleteCallback,
    required this.title,
    this.completeCallback,
    this.outlineColor,
    required this.controller,
    required this.onExpanded,
  });

  @override
  State<ExpandingTaskList> createState() => _ExpandingTaskListState();
}

class _ExpandingTaskListState extends State<ExpandingTaskList> {
  void deleteAll() async {
    if (widget.tasks.isEmpty) return;

    for (List<Task> tasks in widget.tasks.values) {
      for (Task task in tasks) {
        widget.deleteCallback(task);
      }
      tasks.clear();
    }
    widget.tasks.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: ExpansionTile(
          controlAffinity: ListTileControlAffinity.leading,
          shape: const Border(),
          title: Text(widget.title),
          children: [
            SizedBox(
              height: 250,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: FilledButton(onPressed: deleteAll, child: const Text('Delete All')),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: widget.dates.length,
                        itemBuilder: (context, index) => DayCard(
                          date: widget.dates[index],
                          tasks: widget.tasks[widget.dates[index]] ?? [],
                          color: widget.outlineColor,
                          removeCallback: widget.deleteCallback,
                          completeCallback: widget.completeCallback,
                          positionInList: index == 0 ? 0 : (index == widget.tasks.length - 1 ? 2 : 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
