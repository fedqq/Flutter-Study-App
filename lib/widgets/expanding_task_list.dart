import 'package:flutter/material.dart';
import 'package:studyappcs/states/task.dart';
import 'package:studyappcs/widgets/day_card.dart';

class ExpandingTaskList extends StatefulWidget {
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
  final List<DateTime> dates;
  final Map<DateTime, List<Task>> tasks;
  final Function(Task) deleteCallback;
  final Function(Task)? completeCallback;
  final Color? outlineColor;
  final String title;
  final ExpansionTileController controller;
  final void Function() onExpanded;

  @override
  State<ExpandingTaskList> createState() => _ExpandingTaskListState();
}

class _ExpandingTaskListState extends State<ExpandingTaskList> {
  Future<void> deleteAll() async {
    if (widget.tasks.isEmpty) {
      return;
    }

    for (final tasks in widget.tasks.values) {
      tasks
        ..forEach(widget.deleteCallback)
        ..clear();
    }
    widget.tasks.clear();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: FilledButton(onPressed: deleteAll, child: const Text('Delete All')),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: ListView.builder(
                          physics: const ScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: widget.dates.length,
                          itemBuilder: (BuildContext context, int index) => DayCard(
                            date: widget.dates[index],
                            tasks: widget.tasks[widget.dates[index]] ?? <Task>[],
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
