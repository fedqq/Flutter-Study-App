import 'package:flutter/material.dart';
import 'package:flutter_application_1/reused_widgets/gradient_widgets.dart';
import 'package:flutter_application_1/widgets/task_popup.dart';
import 'package:flutter_application_1/states/task.dart';
import 'package:flutter_application_1/utils.dart';
import 'package:intl/intl.dart';

class DayCard extends StatefulWidget {
  final DateTime date;
  final List<Task> tasks;
  final Color? color;
  final void Function(Task) removeCallback;
  final void Function(Task)? completeCallback;
  const DayCard(
      {super.key,
      required this.date,
      required this.tasks,
      this.color,
      required this.removeCallback,
      required this.completeCallback});

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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Theming.purple.withAlpha(80), spreadRadius: -30, blurRadius: 30)],
      ),
      child: GradientOutline(
        gradient: Theming.grayGradient,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
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
                    (index) => InkWell(
                      borderRadius: BorderRadius.circular(Theming.radius + Theming.padding),
                      onLongPress: () => setState(() {
                        if (widget.completeCallback == null) return;
                        widget.tasks[index].completed = true;
                        widget.completeCallback!(widget.tasks[index]);
                      }),
                      child: GradientOutline(
                        gradient: Theming.gradientToDarker(widget.color ?? widget.tasks[index].color, delta: 0.1),
                        innerPadding: 14,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 4.0),
                            Text(
                              widget.tasks[index].name,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(width: 14.0),
                            Icon(widget.tasks[index].getIcon()),
                            const SizedBox(width: 12.0),
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
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
