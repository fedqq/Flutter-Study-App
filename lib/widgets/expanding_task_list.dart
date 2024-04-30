import 'package:flutter/material.dart';
import 'package:flutter_application_1/states/task.dart';
import 'package:flutter_application_1/widgets/day_card.dart';

import '../utils/theming.dart';

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
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16.0),
          width: double.infinity,
          height: 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Theming.grayGradient.colors[1],
          ),
        ),
        ExpansionTile(
          shape: const Border(),
          title: Text(widget.title),
          children: [
            SizedBox(
              height: 250,
              child: ListView.builder(
                itemCount: widget.dates.length,
                itemBuilder: (context, index) => DayCard(
                  date: widget.dates[index],
                  tasks: widget.tasks[widget.dates[index]] ?? [],
                  color: widget.outlineColor,
                  removeCallback: widget.deleteCallback,
                  completeCallback: widget.completeCallback,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
