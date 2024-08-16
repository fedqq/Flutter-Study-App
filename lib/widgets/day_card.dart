import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studyappcs/data_managers/firestore_manager.dart' as firestore_manager;
import 'package:studyappcs/states/task.dart';
import 'package:studyappcs/utils/utils.dart' as theming;
import 'package:studyappcs/widgets/task_popup.dart';

class DayCard extends StatefulWidget {
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
  final DateTime date;
  final List<Task> tasks;
  final Color? color;
  final void Function(Task) removeCallback;
  final void Function(Task)? completeCallback;
  final double progress;
  final int positionInList;

  @override
  State<DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<DayCard> {
  String getDateLabel() {
    final formatted = DateFormat('EEEE, MMMM d, yyyy', 'en-US').format(widget.date);
    if (formatted == DateFormat('EEEE, MMMM d, yyyy', 'en-US').format(DateTime.now().add(const Duration(days: 1)))) {
      return 'Tomorrow';
    } else if (formatted == DateFormat('EEEE, MMMM d, yyyy', 'en-US').format(DateTime.now())) {
      return 'Today';
    } else {
      return formatted;
    }
  }

  Widget buildTaskCard(int index) => InkWell(
        borderRadius: BorderRadius.circular(23),
        child: Card(
          surfaceTintColor: widget.color ?? widget.tasks[index].color,
          elevation: 20,
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.tasks[index].name,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 14),
                IconButton(
                  icon: const Icon(Icons.info_rounded),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => TaskPopup(
                      task: widget.tasks[index],
                      deleteCallback: (Task task) => setState(
                        () {
                          widget.removeCallback(task);
                        },
                      ),
                    ),
                  ).then((_) => setState(() {})),
                ),
                if (!widget.tasks[index].completed)
                  IconButton(
                    icon: const Icon(Icons.check_rounded),
                    onPressed: () async {
                      if (widget.completeCallback == null) {
                        return;
                      }

                      final taskDocs = await firestore_manager.taskDocs;
                      await taskDocs.docs
                          .firstWhere(
                            (QueryDocumentSnapshot<theming.StrMap> a) =>
                                (a['name'] == widget.tasks[index].name) &&
                                (a['date'] == widget.tasks[index].dueDate.millisecondsSinceEpoch),
                          )
                          .reference
                          .update(<Object, Object?>{'completed': true});

                      setState(() {
                        widget.tasks[index].completed = true;
                        widget.completeCallback!(widget.tasks[index]);
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(widget.positionInList == 0 ? 17 : 10),
            topRight: Radius.circular(widget.positionInList == 0 ? 17 : 10),
            bottomLeft: Radius.circular(widget.positionInList == 2 ? 10 : 17),
            bottomRight: Radius.circular(widget.positionInList == 2 ? 10 : 17),
          ),
        ),
        elevation: 1,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.all(8),
                child: Text(
                  getDateLabel(),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              Wrap(
                children: List<Widget>.generate(
                  widget.tasks.length,
                  buildTaskCard,
                ),
              ),
            ],
          ),
        ),
      );
}
