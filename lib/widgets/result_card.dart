import 'package:flutter/material.dart';
import 'package:studyapp/states/test.dart';

class ResultCard extends StatefulWidget {
  final bool? correct;
  final TestCard card;
  final bool editable;
  final String answer;
  final void Function() markCorrect;
  final BorderRadius borderRadius;
  const ResultCard({
    super.key,
    required this.correct,
    required this.card,
    required this.answer,
    required this.editable,
    required this.markCorrect,
    required this.borderRadius,
  });

  @override
  State<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard> {
  @override
  Widget build(BuildContext context) {
    bool correct = widget.correct ?? false;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: widget.borderRadius,
        side: BorderSide(color: correct ? Colors.green : Colors.red),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.card.name, overflow: TextOverflow.ellipsis),
                Text(
                  widget.card.origin,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white.withAlpha(150)),
                ),
              ],
            ),
            if ((!correct) && widget.editable)
              IconButton(
                icon: const Icon(Icons.check_rounded),
                onPressed: () => setState(
                  () {
                    widget.markCorrect();
                    correct = true;
                  },
                ),
              ),
            Column(
              children: [
                Text(widget.card.meaning, overflow: TextOverflow.ellipsis),
                if (!correct)
                  Text(
                    widget.answer,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.red.withAlpha(150)),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
