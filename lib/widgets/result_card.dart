import 'package:flutter/material.dart';
import 'package:flutter_application_1/states/test.dart';
import 'package:flutter_application_1/utils/gradient_widgets.dart';
import 'package:flutter_application_1/utils/theming.dart';

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

    return GradientOutline(
      innerPadding: 16,
      gradient: Theming.gradientToDarker(correct ? Colors.green : Colors.red),
      child: Row(
        children: [
          Text(widget.card.name),
          const SizedBox(width: 50),
          Text(widget.card.origin),
          const Spacer(),
          if (!correct) Text(widget.answer, style: const TextStyle(color: Colors.red)),
          const SizedBox(width: 50),
          Text(widget.card.meaning),
          if ((!correct) && widget.editable)
            IconButton(
              icon: const Icon(Icons.check_rounded),
              onPressed: () => setState(() {
                widget.markCorrect();
                correct = true;
              }),
            ),
        ],
      ),
    );
  }
}
