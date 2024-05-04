import 'package:flutter/material.dart';
import 'package:flutter_application_1/states/test.dart';
import 'package:flutter_application_1/utils/gradient_widgets.dart';
import 'package:flutter_application_1/utils/theming.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

class ResultsPage extends StatefulWidget {
  final List<TestCard> cards;
  final Test test;
  final List<String> answers;
  const ResultsPage({super.key, required this.test, required this.answers, required this.cards});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  @override
  void initState() {
    int i = 0;
    for (TestCard card in widget.cards) {
      if (ratio(widget.answers[i], card.meaning) > 80) {
        widget.test.cards[card] = true;
      }
      i++;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        itemCount: widget.test.cards.length,
        itemBuilder: (context, index) => GradientOutline(
          gradient:
              Theming.gradientToDarker(widget.test.cards[widget.cards[index]] ?? false ? Colors.green : Colors.red),
          child: Row(
            children: [Text(widget.cards[index].name), const Spacer(), Text(widget.answers[index])],
          ),
        ),
      ),
    );
  }
}
