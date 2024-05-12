import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/outlined_card.dart';
import 'package:flutter_application_1/widgets/task_popup.dart';
import 'package:flutter_application_1/states/task.dart';
import 'package:intl/intl.dart';

import '../utils/theming.dart';

class DayCard extends StatefulWidget {
  final DateTime date;
  final List<Task> tasks;
  final Color? color;
  final void Function(Task) removeCallback;
  final void Function(Task)? completeCallback;
  final double progress;
  final int positionInList;
  const DayCard({
    super.key,
    required this.date,
    required this.tasks,
    this.color,
    required this.removeCallback,
    required this.completeCallback,
    this.progress = 1,
    required this.positionInList,
  });

  @override
  State<DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<DayCard> {
  String getDateLabel() {
    String formatted = DateFormat("EEEE, MMMM d, yyyy", 'en-US').format(widget.date);
    if (formatted == DateFormat("EEEE, MMMM d, yyyy", 'en-US').format(DateTime.now().add(const Duration(days: 1)))) {
      return 'Tomorrow';
    } else if (formatted == DateFormat("EEEE, MMMM d, yyyy", 'en-US').format(DateTime.now())) {
      return 'Today';
    } else {
      return formatted;
    }
  }

  Widget buildTaskCard(int index) => InkWell(
        borderRadius: BorderRadius.circular(Theming.radius + Theming.padding),
        onLongPress: () => setState(() {
          if (widget.completeCallback == null) return;
          widget.tasks[index].completed = true;
          widget.completeCallback!(widget.tasks[index]);
        }),
        child: OutlinedCard(
          color: widget.color ?? widget.tasks[index].color,
          elevation: 10,
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.tasks[index].name,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 14.0),
                IconButton(
                  icon: const Icon(Icons.info_rounded),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => TaskPopup(
                      task: widget.tasks[index],
                      deleteCallback: (task) => setState(
                        () => widget.removeCallback(task),
                      ),
                    ),
                  ).then((_) => setState(() {})),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(widget.positionInList == 0 ? 25 + 8 : 10),
          topRight: Radius.circular(widget.positionInList == 0 ? 25 + 8 : 10),
          bottomLeft: Radius.circular(widget.positionInList == 2 ? 25 + 8 : 10),
          bottomRight: Radius.circular(widget.positionInList == 2 ? 25 + 8 : 10),
        ),
      ),
      elevation: 4,
      shadowColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(8.0),
              child: Text(
                getDateLabel(),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
            Wrap(
              children: List.generate(
                widget.tasks.length,
                (index) => buildTaskCard(index),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
