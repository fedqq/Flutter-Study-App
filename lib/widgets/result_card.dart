import 'package:flutter/material.dart';
import 'package:flutter_application_1/states/test.dart';
import 'package:flutter_application_1/utils/outlined_card.dart';
import 'package:latext/latext.dart';

class ResultCard extends StatefulWidget {
  final bool? correct;
  final TestCard card;
  final bool editable;
  final String answer;
  final void Function() markCorrect;
  const ResultCard({
    super.key,
    required this.correct,
    required this.card,
    required this.answer,
    required this.editable,
    required this.markCorrect,
  });

  @override
  State<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard> {
  @override
  Widget build(BuildContext context) {
    bool correct = widget.correct ?? false;

    return OutlinedCard(
      color: correct ? Colors.green : Colors.red,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: [
                Text(widget.card.name, overflow: TextOverflow.ellipsis),
                Text(widget.card.origin, overflow: TextOverflow.ellipsis),
              ],
            ),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: [
                if (!correct)
                  LaTexT(
                    laTeXCode:
                        Text(widget.answer, style: const TextStyle(color: Colors.red), overflow: TextOverflow.ellipsis),
                  ),
                LaTexT(laTeXCode: Text(widget.card.meaning, overflow: TextOverflow.ellipsis)),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
